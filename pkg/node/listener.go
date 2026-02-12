package node

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"fmt"
	"net"
	"sync"
	"sync/atomic"
	"time"

	"github.com/google/uuid"
	"github.com/ivere27/nitella/pkg/api/common"
	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/log"
	"github.com/ivere27/nitella/pkg/node/stats"
	"github.com/ivere27/nitella/pkg/node/stream"
)

// ApprovalRequestTimeout is the maximum time to wait for an approval decision.
// Set to 2 minutes to allow time for mobile approval via FCM push notification.
const ApprovalRequestTimeout = 2 * time.Minute

// TarpitHistoryMaxAge is how long to keep tarpit history entries before cleanup.
// Entries older than this are removed to prevent memory leak from port scanners.
const TarpitHistoryMaxAge = 1 * time.Hour

// TarpitCleanupInterval is how often to run tarpit history cleanup.
const TarpitCleanupInterval = 5 * time.Minute

// closeWrite attempts to close the write side of a connection.
// Handles both plain TCP and TLS connections.
func closeWrite(conn net.Conn) {
	switch c := conn.(type) {
	case *net.TCPConn:
		c.CloseWrite()
	case *tls.Conn:
		c.CloseWrite()
	}
}

// Listener is the interface for a proxy listener (embedded or separated)
type Listener interface {
	Start() error
	Stop() error
	AddRule(rule *pb.Rule)
	RemoveRule(ruleID string) error
	GetRules() []*pb.Rule
	GetStatus() *pb.ProxyStatus
	Subscribe() chan *pb.ConnectionEvent
	Unsubscribe(ch chan *pb.ConnectionEvent)
	GetConnectionBytes(connID string) (in, out int64, ok bool)
	CloseConnection(proxyID, connID string) error
	GetActiveConnections() []*ConnectionMetadata
	CloseAllConnections() error
}

// EmbeddedListener represents a single listening port running as a goroutine
type EmbeddedListener struct {
	ID             string
	Name           string
	ListenAddr     string
	DefaultBackend string
	DefaultAction  common.ActionType // Default action when no rules match: ALLOW, BLOCK, or MOCK
	DefaultMock    common.MockPreset // Mock preset to use when DefaultAction is MOCK
	CertPEM        string
	KeyPEM         string
	CaPEM          string

	ClientAuthType pb.ClientAuthType

	FallbackAction common.FallbackAction
	FallbackMock   common.MockPreset

	listener net.Listener
	quit     chan struct{}
	wg       sync.WaitGroup

	// Runtime stats
	statsMux    sync.RWMutex
	activeConns int64
	totalConns  int64
	bytesIn     int64
	bytesOut    int64
	startTime   time.Time

	// Rules
	rules        []*pb.Rule
	ruleLimiters map[string]*RateLimiter // RuleID -> RateLimiter
	rulesMux     sync.RWMutex

	// Event Broadcasting
	subscribers    map[chan *pb.ConnectionEvent]struct{}
	subscribersMux sync.RWMutex

	geoIP *GeoIPService
	stats *stats.StatsService

	// Approval system
	approval    *ApprovalManager
	globalRules *GlobalRulesStore
	nodeID      string // For approval requests

	// Shutdown context for cancelling long-running operations
	stopCtx    context.Context
	stopCancel context.CancelFunc

	// Tarpit persistence
	tarpitHistory map[string][]time.Time // IP -> List of recent connection times
	tarpitMux     sync.Mutex

	// Active connections tracking
	conns    map[string]*ConnectionMetadata // ConnID -> Metadata
	connsMux sync.RWMutex

	// Cleanup manager for periodic maintenance tasks
	cleanup *CleanupManager
}

func (l *EmbeddedListener) SetFallback(action common.FallbackAction, mock common.MockPreset) {
	l.statsMux.Lock()
	l.FallbackAction = action
	l.FallbackMock = mock
	l.statsMux.Unlock()
}

func (l *EmbeddedListener) getFallback() (common.FallbackAction, common.MockPreset) {
	l.statsMux.RLock()
	defer l.statsMux.RUnlock()
	return l.FallbackAction, l.FallbackMock
}

type ConnectionMetadata struct {
	ID         string
	Conn       net.Conn
	SourceIP   string
	SourcePort int
	DestAddr   string
	StartTime  time.Time
	BytesIn    *int64 // Atomic
	BytesOut   *int64 // Atomic
}

// SetStatsService sets the statistics service for the listener.
// Stats recording is optional and non-blocking.
func (p *EmbeddedListener) SetStatsService(s *stats.StatsService) {
	p.stats = s
}

// SetApprovalManager sets the approval manager for real-time approval workflow
func (p *EmbeddedListener) SetApprovalManager(am *ApprovalManager) {
	p.approval = am
}

// SetGlobalRules sets the global rules store for cross-proxy rules
func (p *EmbeddedListener) SetGlobalRules(gr *GlobalRulesStore) {
	p.globalRules = gr
}

// SetNodeID sets the node ID for approval requests
func (p *EmbeddedListener) SetNodeID(nodeID string) {
	p.nodeID = nodeID
}

func NewEmbeddedListener(id, name, listenAddr, defaultBackend string, defaultAction common.ActionType, defaultMock common.MockPreset, certPEM, keyPEM, caPEM string, clientAuth pb.ClientAuthType, geoIP *GeoIPService) *EmbeddedListener {
	log.Tracef("[TRACE] NewListener: %s, DefaultAction: %v, DefaultMock: '%v', ClientAuth: %v\n", listenAddr, defaultAction, defaultMock, clientAuth)

	return &EmbeddedListener{
		ID:             id,
		Name:           name,
		ListenAddr:     listenAddr,
		DefaultBackend: defaultBackend,
		DefaultAction:  defaultAction,
		DefaultMock:    defaultMock,
		CertPEM:        certPEM,
		KeyPEM:         keyPEM,
		CaPEM:          caPEM,
		ClientAuthType: clientAuth,
		quit:           make(chan struct{}),
		startTime:      time.Now(),
		subscribers:    make(map[chan *pb.ConnectionEvent]struct{}),
		ruleLimiters:   make(map[string]*RateLimiter),
		geoIP:          geoIP,

		tarpitHistory: make(map[string][]time.Time),
		conns:         make(map[string]*ConnectionMetadata),
	}
}

func (p *EmbeddedListener) Subscribe() chan *pb.ConnectionEvent {
	p.subscribersMux.Lock()
	defer p.subscribersMux.Unlock()
	ch := make(chan *pb.ConnectionEvent, 100)
	p.subscribers[ch] = struct{}{}
	return ch
}

func (p *EmbeddedListener) Unsubscribe(ch chan *pb.ConnectionEvent) {
	p.subscribersMux.Lock()
	defer p.subscribersMux.Unlock()
	delete(p.subscribers, ch)
	close(ch)
}

func (p *EmbeddedListener) broadcast(event *pb.ConnectionEvent) {
	// Copy subscribers slice under lock to prevent race with Unsubscribe
	p.subscribersMux.RLock()
	channels := make([]chan *pb.ConnectionEvent, 0, len(p.subscribers))
	for ch := range p.subscribers {
		channels = append(channels, ch)
	}
	p.subscribersMux.RUnlock()

	// Send to all subscribers without holding lock
	for _, ch := range channels {
		select {
		case ch <- event:
		default:
			// Drop if full
		}
	}
}

func (p *EmbeddedListener) Start() error {
	// Initialize shutdown context for cancelling long-running operations
	p.stopCtx, p.stopCancel = context.WithCancel(context.Background())

	log.Tracef("[TRACE] EmbeddedListener.Start: Opening listener on %s", p.ListenAddr)
	ln, err := net.Listen("tcp", p.ListenAddr)
	if err != nil {
		log.Printf("[ERROR] EmbeddedListener.Start: LISTEN FAILED: %v", err)
		return err
	}
	log.Tracef("[TRACE] EmbeddedListener.Start: Listener opened. Configuring TLS...")

	// Enable TLS if configured
	if p.CertPEM != "" && p.KeyPEM != "" {
		cert, err := tls.X509KeyPair([]byte(p.CertPEM), []byte(p.KeyPEM))
		if err != nil {
			ln.Close()
			return fmt.Errorf("failed to load keypair: %v", err)
		}

		tlsConfig := &tls.Config{
			Certificates: []tls.Certificate{cert},
		}

		// Determine ClientAuth strategy
		switch p.ClientAuthType {
		case pb.ClientAuthType_CLIENT_AUTH_NONE:
			tlsConfig.ClientAuth = tls.NoClientCert
		case pb.ClientAuthType_CLIENT_AUTH_REQUEST:
			tlsConfig.ClientAuth = tls.VerifyClientCertIfGiven
		case pb.ClientAuthType_CLIENT_AUTH_REQUIRE:
			tlsConfig.ClientAuth = tls.RequireAndVerifyClientCert
		case pb.ClientAuthType_CLIENT_AUTH_AUTO:
			fallthrough
		default:
			// Default legacy behavior: If CA is present, require it.
			if p.CaPEM != "" {
				tlsConfig.ClientAuth = tls.RequireAndVerifyClientCert
			} else {
				tlsConfig.ClientAuth = tls.NoClientCert
			}
		}

		// If we need to verify certs (Request or Require), we need a CA pool
		if tlsConfig.ClientAuth != tls.NoClientCert {
			if p.CaPEM != "" {
				caPool := x509.NewCertPool()
				if !caPool.AppendCertsFromPEM([]byte(p.CaPEM)) {
					ln.Close()
					return fmt.Errorf("failed to parse CA PEM")
				}
				tlsConfig.ClientCAs = caPool
			} else if tlsConfig.ClientAuth == tls.RequireAndVerifyClientCert {
				// Require but no CA? Fail safe.
				ln.Close()
				return fmt.Errorf("CLIENT_AUTH_REQUIRE requested but no CA PEM provided")
			}
		}

		ln = tls.NewListener(ln, tlsConfig)
	}

	p.listener = ln
	p.ListenAddr = ln.Addr().String()

	// Initialize cleanup manager for periodic maintenance tasks
	p.cleanup = NewCleanupManager(1 * time.Second)
	p.cleanup.Register("tarpit-history", TarpitCleanupInterval, p.cleanupTarpitHistory)
	p.cleanup.Start()

	log.Tracef("[TRACE] EmbeddedListener.Start: Starting accept loop goroutine...")
	p.wg.Add(1)
	go p.acceptLoop()
	log.Printf("[INFO] EmbeddedListener.Start: Started on %s", p.ListenAddr)

	return nil
}

func (p *EmbeddedListener) Stop() error {
	// Cancel the shutdown context to interrupt long-running operations
	if p.stopCancel != nil {
		p.stopCancel()
	}

	close(p.quit)
	if p.listener != nil {
		p.listener.Close()
	}

	// Force close all active connections to unblock WaitGroup
	p.connsMux.Lock()
	for _, meta := range p.conns {
		meta.Conn.Close()
	}
	p.conns = make(map[string]*ConnectionMetadata) // Clear
	p.connsMux.Unlock()

	// Stop all rate limiters to prevent goroutine leaks
	p.rulesMux.Lock()
	for _, limiter := range p.ruleLimiters {
		if limiter != nil {
			limiter.Stop()
		}
	}
	p.ruleLimiters = make(map[string]*RateLimiter) // Clear
	p.rulesMux.Unlock()

	// Stop cleanup manager
	if p.cleanup != nil {
		p.cleanup.Stop()
	}

	// Clear tarpit history to free memory
	p.tarpitMux.Lock()
	p.tarpitHistory = make(map[string][]time.Time)
	p.tarpitMux.Unlock()

	// Wait for goroutines with timeout to prevent hanging during shutdown
	done := make(chan struct{})
	go func() {
		p.wg.Wait()
		close(done)
	}()
	select {
	case <-done:
		// All goroutines finished cleanly
	case <-time.After(5 * time.Second):
		log.Printf("[WARN] EmbeddedListener.Stop: Timeout waiting for goroutines, continuing shutdown")
	}
	log.Printf("[INFO] EmbeddedListener.Stop: Stopped listener on %s", p.ListenAddr)
	return nil
}

// cleanupTarpitHistory removes stale tarpit entries to prevent memory leak.
// Called periodically by CleanupManager.
func (p *EmbeddedListener) cleanupTarpitHistory() {
	p.tarpitMux.Lock()
	defer p.tarpitMux.Unlock()

	now := time.Now()
	removed := 0

	for ip, times := range p.tarpitHistory {
		// Filter out entries older than TarpitHistoryMaxAge
		valid := make([]time.Time, 0, len(times))
		for _, t := range times {
			if now.Sub(t) < TarpitHistoryMaxAge {
				valid = append(valid, t)
			}
		}

		if len(valid) == 0 {
			delete(p.tarpitHistory, ip)
			removed++
		} else if len(valid) < len(times) {
			p.tarpitHistory[ip] = valid
		}
	}

	if removed > 0 {
		log.Printf("[Cleanup] Removed %d stale tarpit history entries", removed)
	}
}

func (p *EmbeddedListener) acceptLoop() {
	defer p.wg.Done()

	for {
		conn, err := p.listener.Accept()
		if err != nil {
			select {
			case <-p.quit:
				return
			default:
				// Log error but continue
				log.Printf("Accept error on %s: %v", p.ID, err)
				continue
			}
		}

		// Double-check if we are stopping to prevent race where Accept returns just after Stop called
		select {
		case <-p.quit:
			conn.Close()
			return
		default:
		}

		p.wg.Add(1)
		go p.handleConn(conn)
	}
}

// Rule Management
func (p *EmbeddedListener) AddRule(rule *pb.Rule) {
	p.rulesMux.Lock()
	defer p.rulesMux.Unlock()

	log.Printf("[Listener] Adding rule: %s (ID: %s) to %s", rule.Name, rule.Id, p.ID)

	// Create RateLimiter if configured
	if rule.RateLimit != nil {
		p.ruleLimiters[rule.Id] = NewRateLimiter(rule.RateLimit)
	}

	// Insertion sort by priority (descending) - efficient single allocation
	insertIdx := len(p.rules)
	for i, r := range p.rules {
		if rule.Priority > r.Priority {
			insertIdx = i
			break
		}
	}
	// Insert at position without nested append
	p.rules = append(p.rules, nil)
	copy(p.rules[insertIdx+1:], p.rules[insertIdx:])
	p.rules[insertIdx] = rule
}

func (p *EmbeddedListener) RemoveRule(ruleID string) error {
	p.rulesMux.Lock()
	defer p.rulesMux.Unlock()

	for i, r := range p.rules {
		if r.Id == ruleID {
			// Remove from slice
			p.rules = append(p.rules[:i], p.rules[i+1:]...)

			// Stop and remove rate limiter if exists
			if limiter, ok := p.ruleLimiters[ruleID]; ok && limiter != nil {
				limiter.Stop()
			}
			delete(p.ruleLimiters, ruleID)
			return nil
		}
	}

	return fmt.Errorf("rule not found")
}

// GetRules returns a copy of all rules for this listener
func (p *EmbeddedListener) GetRules() []*pb.Rule {
	p.rulesMux.RLock()
	defer p.rulesMux.RUnlock()

	log.Printf("[Listener] GetRules %s: %d rules", p.ID, len(p.rules))

	// Return a copy to avoid race conditions
	rules := make([]*pb.Rule, len(p.rules))
	copy(rules, p.rules)
	return rules
}

func (p *EmbeddedListener) handleConn(conn net.Conn) {
	defer p.wg.Done()

	// Fast exit if stopping
	select {
	case <-p.quit:
		conn.Close()
		return
	default:
	}

	connStart := time.Now()
	connID := uuid.New().String()
	sourceAddr := conn.RemoteAddr().String()
	sourceIP, sourcePortStr, _ := net.SplitHostPort(sourceAddr)
	sourcePort := 0
	fmt.Sscanf(sourcePortStr, "%d", &sourcePort)

	var connBytesIn, connBytesOut int64

	// Track connection for forced shutdown & listing
	p.connsMux.Lock()
	p.conns[connID] = &ConnectionMetadata{
		ID:         connID,
		Conn:       conn,
		SourceIP:   sourceIP,
		SourcePort: sourcePort,
		StartTime:  connStart,
		BytesIn:    &connBytesIn,
		BytesOut:   &connBytesOut,
	}
	p.connsMux.Unlock()

	// Ensure removal on exit
	defer func() {
		p.connsMux.Lock()
		delete(p.conns, connID)
		p.connsMux.Unlock()
	}()

	// GeoIP Lookup
	var geoInfo *pbCommon.GeoInfo
	if p.geoIP != nil {
		geoInfo = p.geoIP.Lookup(sourceIP)
	}

	// Emit CONNECTED
	p.broadcast(&pb.ConnectionEvent{
		ConnId:     connID,
		SourceIp:   sourceIP,
		SourcePort: int32(sourcePort),
		EventType:  pb.EventType_EVENT_TYPE_CONNECTED,
		Timestamp:  connStart.Unix(),
		Geo:        geoInfo,
	})

	// 0. Check Global Rules first (highest priority)
	// Note: Global ALLOW only prevents blocking, it does NOT bypass REQUIRE_APPROVAL.
	// This ensures human oversight is maintained for high-security scenarios.
	globalAllowed := false
	if p.globalRules != nil {
		if matched, globalAction := p.globalRules.Check(sourceIP); matched {
			if globalAction == common.ActionType_ACTION_TYPE_BLOCK {
				p.broadcast(&pb.ConnectionEvent{
					ConnId:      connID,
					SourceIp:    sourceIP,
					EventType:   pb.EventType_EVENT_TYPE_BLOCKED,
					Timestamp:   time.Now().Unix(),
					ActionTaken: common.ActionType_ACTION_TYPE_BLOCK,
					Geo:         geoInfo,
				})
				log.Printf("Blocked by global rule: %s", sourceIP)
				conn.Close()
				return
			} else if globalAction == common.ActionType_ACTION_TYPE_ALLOW {
				// Global allow - prevents blocking but still respects REQUIRE_APPROVAL
				log.Tracef("[TRACE] Global allow rule matched for %s (will override BLOCK, not REQUIRE_APPROVAL)", sourceIP)
				globalAllowed = true
			}
		}
	}

	// 1. Check Rules
	rule, limiter := p.evaluateRules(conn, geoInfo)

	action := p.DefaultAction // Use configured default action (allow, block, or mock)
	log.Tracef("[TRACE] handleConn: Source=%s, DefaultAction=%v, DefaultMock=%s\n", sourceIP, action, p.DefaultMock)

	ruleId := "default"
	backend := ""
	var tlsSessionID string      // For approval cache tracking
	var hasApprovalEntry bool    // Track if this conn has an approval cache entry
	if rule != nil {
		action = rule.Action
		backend = rule.TargetBackend
		ruleId = rule.Id
	} else if action == common.ActionType_ACTION_TYPE_MOCK {
		// Create temporary rule for default mock
		rule = &pb.Rule{
			Action: common.ActionType_ACTION_TYPE_MOCK,
			MockResponse: &pb.MockConfig{
				Preset: p.DefaultMock,
			},
		}
	}

	// Apply global allow: overrides BLOCK but NOT REQUIRE_APPROVAL
	// This ensures human oversight is maintained for high-security scenarios
	if globalAllowed && action == common.ActionType_ACTION_TYPE_BLOCK {
		log.Tracef("[TRACE] Global allow overriding BLOCK for %s", sourceIP)
		action = common.ActionType_ACTION_TYPE_ALLOW
	}

	// 2. Handle REQUIRE_APPROVAL action
	if action == common.ActionType_ACTION_TYPE_REQUIRE_APPROVAL {
		if p.approval == nil {
			// No approval manager configured - fall back to block
			log.Printf("[WARN] Action REQUIRE_APPROVAL but no ApprovalManager configured - blocking")
			action = common.ActionType_ACTION_TYPE_BLOCK
		} else {
			// Extract TLS session ID for binding (prevents replay attacks)
			// Priority: TLSUnique -> connID
			// - TLSUnique: Best option, cryptographically bound to TLS session
			// - connID: Fallback when TLSUnique is empty (common in TLS 1.3 after first request)
			// This prevents IP-based binding weakness (sharing approval across same IP).
			isTLS := false
			if tc, ok := conn.(*tls.Conn); ok {
				isTLS = true
				state := tc.ConnectionState()
				if len(state.TLSUnique) > 0 {
					tlsSessionID = fmt.Sprintf("%x", state.TLSUnique)
				}
			}

			// If still empty AND it is a TLS connection (TLS 1.3), strictly bind to this specific connection
			// to prevent IP-based binding weakness (sharing approval across same IP).
			// For plain TCP (!isTLS), we allow empty ID to support IP-based caching (as session ID is impossible).
			if tlsSessionID == "" && isTLS {
				tlsSessionID = connID
			}

			// Check cache first
			if found, allowed := p.approval.CheckCache(sourceIP, ruleId, tlsSessionID); found {
				if allowed {
					action = common.ActionType_ACTION_TYPE_ALLOW
					// Track this connection under the approval with live byte counters
					p.approval.SetConnID(sourceIP, ruleId, tlsSessionID, connID, &connBytesIn, &connBytesOut)
					hasApprovalEntry = true
				} else {
					action = common.ActionType_ACTION_TYPE_BLOCK
					p.approval.IncrementBlockedCount(sourceIP, ruleId, tlsSessionID)
				}
			} else {
				// Cache miss - request approval using async pattern
				// This allows immediate cleanup if the connection closes during approval wait
				ctx, cancel := context.WithTimeout(p.stopCtx, ApprovalRequestTimeout)
				defer cancel()

				// Build approval request info
				geoCountry, geoCity, geoISP := "", "", ""
				if geoInfo != nil {
					geoCountry = geoInfo.Country
					geoCity = geoInfo.City
					geoISP = geoInfo.Isp
				}

				info, err := json.Marshal(map[string]interface{}{
					"source_ip":   sourceIP,
					"destination": p.DefaultBackend,
					"proxy_id":    p.ID,
					"proxy_name":  p.Name,
					"rule_id":     ruleId,
					"geo_country": geoCountry,
					"geo_city":    geoCity,
					"geo_isp":     geoISP,
				})
				if err != nil {
					log.Errorf("failed to marshal approval request info: %v", err)
				}

				meta := ApprovalRequestMeta{
					ProxyID:    p.ID,
					SourceIP:   sourceIP,
					DestAddr:   p.DefaultBackend,
					RuleID:     ruleId,
					GeoCountry: geoCountry,
					GeoCity:    geoCity,
					GeoISP:     geoISP,
				}

				// Emit PENDING event
				p.broadcast(&pb.ConnectionEvent{
					ConnId:    connID,
					SourceIp:  sourceIP,
					EventType: pb.EventType_EVENT_TYPE_PENDING_APPROVAL,
					Timestamp: time.Now().Unix(),
					Geo:       geoInfo,
				})

				// Start approval request (non-blocking)
				resultCh, err := p.approval.BeginApprovalRequest(connID, p.nodeID, string(info), meta)
				if err != nil {
					log.Printf("[WARN] Approval request rejected: %v - blocking", err)
					action = common.ActionType_ACTION_TYPE_BLOCK
				} else {
					// Ensure cleanup on any exit path - this frees the pending slot immediately
					// when the connection handler exits (including if connection closes)
					defer p.approval.CancelApprovalRequest(connID)

					// Wait for approval decision
					// Protection against ghost requests:
					// 1. Per-IP limit (DefaultMaxPendingPerIP=10) limits single-source attacks
					// 2. Async pattern + defer ensures cleanup when connection handler exits
					// 3. Timeout (ApprovalRequestTimeout) bounds maximum wait time
					//
					// Note: We can't reliably detect TCP RST without consuming data from
					// the connection. Per-IP limits provide the primary DoS protection.
					result, err := p.approval.WaitForApproval(ctx, connID, resultCh, nil)
					if err != nil {
						// Timeout or error - block
						log.Printf("[WARN] Approval request failed: %v - blocking", err)
						action = common.ActionType_ACTION_TYPE_BLOCK
					} else if result.Allowed {
						action = common.ActionType_ACTION_TYPE_ALLOW
						// Cache the decision
						if result.Duration > 0 {
							p.approval.AddToCacheWithGeo(sourceIP, ruleId, p.ID, tlsSessionID, true, result.Duration, geoCountry, geoCity, geoISP)
							p.approval.SetConnID(sourceIP, ruleId, tlsSessionID, connID, &connBytesIn, &connBytesOut)
							hasApprovalEntry = true
						}
					} else {
						action = common.ActionType_ACTION_TYPE_BLOCK
						// Cache block decision too
						if result.Duration > 0 {
							p.approval.AddToCacheWithGeo(sourceIP, ruleId, p.ID, tlsSessionID, false, result.Duration, geoCountry, geoCity, geoISP)
						}
					}
				}
			}
		}
	}

	// Helper for fallback logic
	handleFallback := func(errReason string) {
		// Get fallback config with proper synchronization
		fallbackAction, fallbackMock := p.getFallback()

		// Fallback Logic
		action := common.FallbackAction(fallbackAction)
		if action == common.FallbackAction_FALLBACK_ACTION_UNSPECIFIED {
			if p.DefaultMock != common.MockPreset_MOCK_PRESET_UNSPECIFIED {
				action = common.FallbackAction_FALLBACK_ACTION_MOCK
			} else {
				action = common.FallbackAction_FALLBACK_ACTION_CLOSE
			}
		}

		if action == common.FallbackAction_FALLBACK_ACTION_MOCK { // Mock
			preset := fallbackMock
			if preset == common.MockPreset_MOCK_PRESET_UNSPECIFIED {
				preset = p.DefaultMock
			}

			if preset != common.MockPreset_MOCK_PRESET_UNSPECIFIED {
				log.Printf("Fallback to Mock (%s): %s", errReason, preset)
				p.HandleMockConnection(conn, &pb.Rule{
					Action:       common.ActionType_ACTION_TYPE_MOCK,
					MockResponse: &pb.MockConfig{Preset: preset},
				})

				// Record stats for fallback mocked connection
				if p.stats != nil {
					fallbackRuleID := "fallback-" + errReason
					p.stats.RecordConnection(&stats.ConnectionEvent{
						SourceIP:   sourceIP,
						SourcePort: int32(sourcePort),
						StartTime:  connStart,
						EndTime:    time.Now(),
						Action:     int32(common.ActionType_ACTION_TYPE_MOCK),
						RuleID:     fallbackRuleID,
						Geo:        geoInfo,
					})
				}
				conn.Close()
				return
			}
		}

		// Close (default)
		log.Printf("Closing connection (%s)", errReason)
		conn.Close()
	}

	if action == common.ActionType_ACTION_TYPE_BLOCK {
		// Emit BLOCKED
		p.broadcast(&pb.ConnectionEvent{
			ConnId:      connID,
			SourceIp:    sourceIP,
			EventType:   pb.EventType_EVENT_TYPE_BLOCKED,
			Timestamp:   time.Now().Unix(),
			ActionTaken: common.ActionType_ACTION_TYPE_BLOCK,
			Geo:         geoInfo,
		})

		// Record stats for blocked connection
		if p.stats != nil {
			blockRuleID := ""
			if rule != nil {
				blockRuleID = rule.Id
			}
			p.stats.RecordConnection(&stats.ConnectionEvent{
				SourceIP:   sourceIP,
				SourcePort: int32(sourcePort),
				StartTime:  connStart,
				EndTime:    time.Now(),
				Action:     int32(common.ActionType_ACTION_TYPE_BLOCK),
				RuleID:     blockRuleID,
				Geo:        geoInfo,
			})
		}

		// Safely get geo country for log message
		geoCountry := "unknown"
		if geoInfo != nil {
			geoCountry = geoInfo.GetCountry()
		}
		log.Printf("Blocked connection from %s (%s)", conn.RemoteAddr(), geoCountry)

		// Use Fallback Logic
		handleFallback("block")
		return
	}

	if action == common.ActionType_ACTION_TYPE_MOCK {
		mockStart := time.Now()
		// If no rule matched, use DefaultMock preset
		mockRule := rule
		if mockRule == nil {
			mockRule = &pb.Rule{
				Action: common.ActionType_ACTION_TYPE_MOCK,
				MockResponse: &pb.MockConfig{
					Preset: p.DefaultMock,
				},
			}
		}
		p.HandleMockConnection(conn, mockRule)

		// Record stats for mocked connection
		if p.stats != nil {
			mockRuleID := ""
			if rule != nil {
				mockRuleID = rule.Id
			}
			p.stats.RecordConnection(&stats.ConnectionEvent{
				SourceIP:   sourceIP,
				SourcePort: int32(sourcePort),
				StartTime:  mockStart,
				EndTime:    time.Now(),
				Action:     int32(common.ActionType_ACTION_TYPE_MOCK),
				RuleID:     mockRuleID,
				Geo:        geoInfo,
			})
		}

		conn.Close()
		return
	}

	// 2. Determine Backend
	targetBackend := p.DefaultBackend
	if backend != "" {
		targetBackend = backend
	}

	// Update Metadata with Target
	p.connsMux.Lock()
	if meta, ok := p.conns[connID]; ok {
		meta.DestAddr = targetBackend
	}
	p.connsMux.Unlock()

	if targetBackend == "" {
		log.Printf("No backend for connection from %s", conn.RemoteAddr())
		handleFallback("empty-backend")
		return
	}

	// 3. Connect to Backend
	defer func() {
		connDuration := time.Since(connStart)
		conn.Close()

		// Report result to RateLimiter (fail2ban logic)
		if limiter != nil {
			limiter.ReportResult(sourceIP, connDuration)
		}

		// Emit CLOSED
		p.broadcast(&pb.ConnectionEvent{
			ConnId:    connID,
			SourceIp:  sourceIP,
			EventType: pb.EventType_EVENT_TYPE_CLOSED,
			Timestamp: time.Now().Unix(),
		})
	}()

	p.incrementActiveConns()
	defer p.decrementActiveConns()

	backendConn, err := net.DialTimeout("tcp", targetBackend, 5*time.Second)
	if err != nil {
		log.Printf("Failed to dial backend %s: %v", targetBackend, err)
		handleFallback("dial-failed")
		return
	}
	defer backendConn.Close()

	// Bidirectional copy - track bytes for stats
	var wg sync.WaitGroup
	wg.Add(2)

	go func() {
		defer wg.Done()
		// conn -> backend (BytesIn)
		// Use SpliceProxy for zero-copy on Linux (if TCP) or pooled buffer copy otherwise
		n, _ := stream.SpliceProxy(backendConn, conn, &connBytesIn)
		p.addBytesIn(n)
		closeWrite(backendConn)
	}()

	go func() {
		defer wg.Done()
		// backend -> conn (BytesOut)
		// Use SpliceProxy for zero-copy on Linux (if TCP) or pooled buffer copy otherwise
		n, _ := stream.SpliceProxy(conn, backendConn, &connBytesOut)
		p.addBytesOut(n)
		closeWrite(conn)
	}()

	wg.Wait()

	// Update approval cache with final byte counts and remove connection tracking
	if hasApprovalEntry && p.approval != nil {
		p.approval.UpdateBytes(sourceIP, ruleId, tlsSessionID,
			atomic.LoadInt64(&connBytesIn), atomic.LoadInt64(&connBytesOut))
		// Remove this connection from tracking (keeps ConnIDs bounded to active connections)
		p.approval.RemoveConnID(sourceIP, ruleId, tlsSessionID, connID)
	}

	// Record stats after connection completes (non-blocking)
	if p.stats != nil {
		allowRuleID := ""
		if rule != nil {
			allowRuleID = rule.Id
		}
		p.stats.RecordConnection(&stats.ConnectionEvent{
			SourceIP:   sourceIP,
			SourcePort: int32(sourcePort),
			StartTime:  connStart,
			EndTime:    time.Now(),
			BytesIn:    atomic.LoadInt64(&connBytesIn),
			BytesOut:   atomic.LoadInt64(&connBytesOut),
			Action:     int32(action),
			RuleID:     allowRuleID,
			Geo:        geoInfo,
		})
	}
}

func (p *EmbeddedListener) evaluateRules(conn net.Conn, geo *pbCommon.GeoInfo) (*pb.Rule, *RateLimiter) {
	p.rulesMux.RLock()
	defer p.rulesMux.RUnlock()

	// Need to extract IP for rate limit check
	sourceAddr := conn.RemoteAddr().String()
	sourceIP, _, _ := net.SplitHostPort(sourceAddr)

	for _, rule := range p.rules {
		if MatchRule(rule, conn, geo) {
			// Check Rate Limit if present
			if limiter, ok := p.ruleLimiters[rule.Id]; ok {
				if !limiter.Check(sourceIP) {
					// Blocked by rate limiter -> Return a temporary block rule
					blockRule := &pb.Rule{
						Id:     rule.Id,
						Action: common.ActionType_ACTION_TYPE_BLOCK,
					}
					return blockRule, nil
				}
				// Track this connection attempt
				limiter.TrackConnection(sourceIP)
				return rule, limiter
			}

			return rule, nil
		}
	}

	// Default: No rule matched
	return nil, nil
}

// Stats helpers
func (p *EmbeddedListener) incrementActiveConns() {
	p.statsMux.Lock()
	p.activeConns++
	p.totalConns++
	p.statsMux.Unlock()
}

func (p *EmbeddedListener) decrementActiveConns() {
	p.statsMux.Lock()
	p.activeConns--
	p.statsMux.Unlock()
}

func (p *EmbeddedListener) addBytesIn(n int64) {
	p.statsMux.Lock()
	p.bytesIn += n
	p.statsMux.Unlock()
}

func (p *EmbeddedListener) addBytesOut(n int64) {
	p.statsMux.Lock()
	p.bytesOut += n
	p.statsMux.Unlock()
}

func (p *EmbeddedListener) GetStatus() *pb.ProxyStatus {
	p.statsMux.RLock()
	bytesIn := p.bytesIn
	bytesOut := p.bytesOut
	activeConns := p.activeConns
	totalConns := p.totalConns
	p.statsMux.RUnlock()

	// Also add bytes from currently active connections (real-time)
	p.connsMux.RLock()
	for _, meta := range p.conns {
		if meta.BytesIn != nil {
			bytesIn += atomic.LoadInt64(meta.BytesIn)
		}
		if meta.BytesOut != nil {
			bytesOut += atomic.LoadInt64(meta.BytesOut)
		}
	}
	p.connsMux.RUnlock()

	return &pb.ProxyStatus{
		ProxyId:           p.ID,
		Running:           p.listener != nil,
		ListenAddr:        p.ListenAddr,
		DefaultBackend:    p.DefaultBackend,
		ActiveConnections: activeConns,
		TotalConnections:  totalConns,
		BytesIn:           bytesIn,
		BytesOut:          bytesOut,
		UptimeSeconds:     int64(time.Since(p.startTime).Seconds()),
		DefaultAction:     p.DefaultAction,
		DefaultMock:       p.DefaultMock,
		FallbackAction:    common.FallbackAction(p.FallbackAction),
		FallbackMock:      p.FallbackMock,
		ClientAuthType:    p.ClientAuthType,
	}
}

// Connection Management

func (p *EmbeddedListener) GetActiveConnections() []*ConnectionMetadata {
	p.connsMux.RLock()
	defer p.connsMux.RUnlock()

	conns := make([]*ConnectionMetadata, 0, len(p.conns))
	for _, meta := range p.conns {
		// Create a snapshot copy with nil-safe byte access
		var bytesIn, bytesOut int64
		if meta.BytesIn != nil {
			bytesIn = atomic.LoadInt64(meta.BytesIn)
		}
		if meta.BytesOut != nil {
			bytesOut = atomic.LoadInt64(meta.BytesOut)
		}
		conns = append(conns, &ConnectionMetadata{
			ID:         meta.ID,
			SourceIP:   meta.SourceIP,
			SourcePort: meta.SourcePort,
			DestAddr:   meta.DestAddr,
			StartTime:  meta.StartTime,
			BytesIn:    protoInt64(bytesIn),
			BytesOut:   protoInt64(bytesOut),
		})
	}
	return conns
}

func (p *EmbeddedListener) CloseConnection(proxyID, connID string) error {
	if proxyID != "" && proxyID != p.ID {
		return fmt.Errorf("proxy ID mismatch")
	}

	p.connsMux.Lock()
	defer p.connsMux.Unlock()

	if meta, ok := p.conns[connID]; ok {
		meta.Conn.Close()
		// Do not delete here, let the handleConn defer clean it up
		return nil
	}
	return fmt.Errorf("connection not found")
}

func (p *EmbeddedListener) CloseAllConnections() error {
	p.connsMux.Lock()
	defer p.connsMux.Unlock()

	for _, meta := range p.conns {
		meta.Conn.Close()
	}
	return nil
}

func (p *EmbeddedListener) GetConnectionBytes(connID string) (in, out int64, ok bool) {
	p.connsMux.RLock()
	defer p.connsMux.RUnlock()

	if meta, found := p.conns[connID]; found {
		if meta.BytesIn != nil {
			in = atomic.LoadInt64(meta.BytesIn)
		}
		if meta.BytesOut != nil {
			out = atomic.LoadInt64(meta.BytesOut)
		}
		return in, out, true
	}
	return 0, 0, false
}

func protoInt64(v int64) *int64 {
	return &v
}
