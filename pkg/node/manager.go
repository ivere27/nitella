package node

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/google/uuid"
	_ "github.com/mattn/go-sqlite3"
	"gopkg.in/yaml.v3"
	"xorm.io/xorm"

	"github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/proxy"
	"github.com/ivere27/nitella/pkg/config"
	"github.com/ivere27/nitella/pkg/geoip"
	"github.com/ivere27/nitella/pkg/log"
	"github.com/ivere27/nitella/pkg/node/health"
	"github.com/ivere27/nitella/pkg/node/stats"
)

// ListenerMode defines how proxy listeners are created.
type ListenerMode int

const (
	// ListenerModeFfi uses FFI transport (in-process, zero-copy).
	// This is the most efficient mode for single-process deployments.
	ListenerModeFfi ListenerMode = iota

	// ListenerModeProcess spawns child processes via IPC.
	// This provides isolation - if a listener crashes, only that listener is affected.
	ListenerModeProcess
)

// String returns the string representation of ListenerMode.
func (m ListenerMode) String() string {
	switch m {
	case ListenerModeFfi:
		return "ffi"
	case ListenerModeProcess:
		return "process"
	default:
		return "unknown"
	}
}

type ManagedProxy struct {
	Listener   Listener // nil if stopped
	Model      *ProxyModel
	eventSub   chan *pb.ConnectionEvent // Subscription channel for event forwarding
	cancelSub  func()                   // Function to stop the event forwarder goroutine
}

type ProxyManager struct {
	proxies    map[string]*ManagedProxy
	mu         sync.RWMutex
	mode       ListenerMode
	ConfigPath string

	db *xorm.Engine

	// Global Event Bus
	globalSubs   map[chan *pb.ConnectionEvent]struct{}
	globalSubsMu sync.RWMutex

	// Shared Services
	GeoIP       *GeoIPService
	Stats       *stats.StatsService
	HealthCheck *health.HealthChecker

	// Global Runtime Rules (block/allow across all proxies)
	GlobalRules *GlobalRulesStore

	// Approval System
	Approval *ApprovalManager

	// Node Identity
	NodeID string
}

// NewProxyManager creates a new ProxyManager with the specified listener mode.
func NewProxyManager(mode ListenerMode) *ProxyManager {
	// GeoIP service starts with nil client - caller should set it via GeoIP.SetClient()
	geoIP := NewGeoIPService(nil)

	pm := &ProxyManager{
		proxies:     make(map[string]*ManagedProxy),
		mode:        mode,
		globalSubs:  make(map[chan *pb.ConnectionEvent]struct{}),
		GeoIP:       geoIP,
		GlobalRules: NewGlobalRulesStore(),
	}

	// Initialize HealthCheck immediately so we can add services dynamically
	pm.HealthCheck = health.NewHealthChecker(nil)
	pm.HealthCheck.Start()

	return pm
}

// NewProxyManagerWithBool creates a ProxyManager for backward compatibility.
// Deprecated: Use NewProxyManager(ListenerMode) instead.
func NewProxyManagerWithBool(useEmbedded bool) *ProxyManager {
	mode := ListenerModeProcess
	if useEmbedded {
		mode = ListenerModeFfi
	}
	return NewProxyManager(mode)
}

// SetApprovalManager sets the approval manager and wires it to all proxies
func (m *ProxyManager) SetApprovalManager(am *ApprovalManager) {
	m.Approval = am
	// Wire to existing proxies
	m.mu.RLock()
	for _, p := range m.proxies {
		if p.Listener != nil {
			switch l := p.Listener.(type) {
			case *EmbeddedListener:
				l.SetApprovalManager(am)
				l.SetGlobalRules(m.GlobalRules)
				l.SetNodeID(m.NodeID)
			case *FfiListener:
				l.SetApprovalManager(am)
				l.SetGlobalRules(m.GlobalRules)
				l.SetNodeID(m.NodeID)
			}
		}
	}
	m.mu.RUnlock()
}

// SetNodeID sets the node identifier for approval requests
func (m *ProxyManager) SetNodeID(nodeID string) {
	m.NodeID = nodeID
	// Wire to existing proxies
	m.mu.RLock()
	for _, p := range m.proxies {
		if p.Listener != nil {
			switch l := p.Listener.(type) {
			case *EmbeddedListener:
				l.SetNodeID(nodeID)
			case *FfiListener:
				l.SetNodeID(nodeID)
			}
		}
	}
	m.mu.RUnlock()
}

// GetGlobalRules returns the global rules store
func (m *ProxyManager) GetGlobalRules() *GlobalRulesStore {
	return m.GlobalRules
}

// SetStatsService sets the statistics service for all proxies
func (m *ProxyManager) SetStatsService(s *stats.StatsService) {
	m.Stats = s
	// Update existing proxies
	m.mu.RLock()
	for _, p := range m.proxies {
		if p.Listener != nil {
			switch l := p.Listener.(type) {
			case *EmbeddedListener:
				l.SetStatsService(s)
			case *FfiListener:
				l.SetStatsService(s)
			}
		}
	}
	m.mu.RUnlock()
}

// GetStatsService returns the stats service
func (m *ProxyManager) GetStatsService() *stats.StatsService {
	return m.Stats
}

// SubscribeGlobal adds a channel to receive events from ALL proxies
func (m *ProxyManager) SubscribeGlobal() chan *pb.ConnectionEvent {
	m.globalSubsMu.Lock()
	defer m.globalSubsMu.Unlock()
	ch := make(chan *pb.ConnectionEvent, 100)
	m.globalSubs[ch] = struct{}{}
	return ch
}

func (m *ProxyManager) UnsubscribeGlobal(ch chan *pb.ConnectionEvent) {
	m.globalSubsMu.Lock()
	defer m.globalSubsMu.Unlock()
	delete(m.globalSubs, ch)
	close(ch)
}

func (m *ProxyManager) broadcastGlobal(event *pb.ConnectionEvent) {
	m.globalSubsMu.RLock()
	defer m.globalSubsMu.RUnlock()
	for ch := range m.globalSubs {
		select {
		case ch <- event:
		default:
			// Drop if full
		}
	}
}

// startEventForwarder subscribes to proxy events and forwards them to the global bus.
// Returns a cancel function to stop the forwarder goroutine.
func (m *ProxyManager) startEventForwarder(mp *ManagedProxy) {
	if mp.Listener == nil {
		return
	}

	// Stop any existing forwarder first
	m.stopEventForwarder(mp)

	subCh := mp.Listener.Subscribe()
	done := make(chan struct{})

	mp.eventSub = subCh
	mp.cancelSub = func() {
		close(done)
		if mp.Listener != nil {
			mp.Listener.Unsubscribe(subCh)
		}
	}

	go func() {
		for {
			select {
			case <-done:
				return
			case event, ok := <-subCh:
				if !ok {
					return
				}
				m.broadcastGlobal(event)
			}
		}
	}()
}

// stopEventForwarder stops the event forwarder goroutine for a proxy.
func (m *ProxyManager) stopEventForwarder(mp *ManagedProxy) {
	if mp.cancelSub != nil {
		mp.cancelSub()
		mp.cancelSub = nil
		mp.eventSub = nil
	}
}

func convertHealthCheck(cfg *pb.HealthCheckConfig) *config.HealthCheck {
	if cfg == nil {
		return nil
	}

	typeStr := "tcp"
	switch cfg.Type {
	case pb.HealthCheckType_HEALTH_CHECK_TYPE_HTTP:
		typeStr = "http"
	case pb.HealthCheckType_HEALTH_CHECK_TYPE_HTTPS:
		typeStr = "https"
	case pb.HealthCheckType_HEALTH_CHECK_TYPE_TCP:
		typeStr = "tcp"
	}

	return &config.HealthCheck{
		Interval:       cfg.Interval,
		Timeout:        cfg.Timeout,
		Type:           typeStr,
		Path:           cfg.Path,
		ExpectedStatus: int(cfg.ExpectedStatus),
	}
}

func sanitizeAddress(addr string) string {
	return strings.TrimSpace(addr)
}

func (m *ProxyManager) CreateProxyWithID(id string, req *pb.CreateProxyRequest) (*pb.CreateProxyResponse, error) {
	m.mu.Lock()
	defer m.mu.Unlock()

	// Check if already listening on this address
	// Skip check for port 0 (random port) addresses
	isRandomPort := strings.HasSuffix(req.ListenAddr, ":0")
	if !isRandomPort {
		for _, p := range m.proxies {
			if p.Model != nil && p.Model.ListenAddr == req.ListenAddr {
				return &pb.CreateProxyResponse{
					Success:      false,
					ErrorMessage: fmt.Sprintf("Address %s is already in use by proxy %s", req.ListenAddr, p.Model.Name),
				}, nil
			}
		}
	}

	// Use provided ID or generate
	if id == "" {
		id = uuid.New().String()
	}

	var proxy Listener

	// Sanitize inputs
	req.ListenAddr = sanitizeAddress(req.ListenAddr)
	req.DefaultBackend = sanitizeAddress(req.DefaultBackend)

	// Use Enum directly
	action := req.DefaultAction

	// Auto-set DefaultAction to MOCK if DefaultMock is specified but action is unspecified
	if action == common.ActionType_ACTION_TYPE_UNSPECIFIED && req.DefaultMock != common.MockPreset_MOCK_PRESET_UNSPECIFIED {
		action = common.ActionType_ACTION_TYPE_MOCK
	}

	switch m.mode {
	case ListenerModeFfi:
		// FFI mode: use FfiListener (in-process via synurang FFI)
		fl := NewFfiListener(id, req.Name, req.ListenAddr, req.DefaultBackend, action, req.DefaultMock, req.CertPem, req.KeyPem, req.CaPem, req.ClientAuthType, m.GeoIP)
		if m.Stats != nil {
			fl.SetStatsService(m.Stats)
		}
		fl.SetFallback(req.FallbackAction, req.FallbackMock)
		if m.GlobalRules != nil {
			fl.SetGlobalRules(m.GlobalRules)
		}
		if m.Approval != nil {
			fl.SetApprovalManager(m.Approval)
		}
		if m.NodeID != "" {
			fl.SetNodeID(m.NodeID)
		}
		proxy = fl

	case ListenerModeProcess:
		// Process mode: spawn a child process for each proxy
		pl := NewProcessListener(id, req.Name, req.ListenAddr, req.DefaultBackend, action, req.DefaultMock, req.CertPem, req.KeyPem, req.CaPem, req.ClientAuthType)
		pl.SetFallback(req.FallbackAction, req.FallbackMock)
		proxy = pl
	}

	if err := proxy.Start(); err != nil {
		return &pb.CreateProxyResponse{
			Success:      false,
			ErrorMessage: fmt.Sprintf("Failed to start listener: %v", err),
		}, nil
	}

	hcJSON := ""
	if req.HealthCheck != nil {
		b, _ := json.Marshal(req.HealthCheck)
		hcJSON = string(b)
	}

	proxyModel := &ProxyModel{
		ID:              id,
		Name:            req.Name,
		ListenAddr:      req.ListenAddr,
		DefaultBackend:  req.DefaultBackend,
		DefaultAction:   int(action),
		DefaultMock:     MockPresetToString(req.DefaultMock),
		FallbackAction:  int(req.FallbackAction),
		FallbackMock:    MockPresetToString(req.FallbackMock),
		ClientAuthType:  int(req.ClientAuthType),
		Enabled:         true,
		CertPEM:         req.CertPem,
		KeyPEM:          req.KeyPem,
		CaPEM:           req.CaPem,
		HealthCheckJSON: hcJSON,
		CreatedAt:       time.Now(),
		UpdatedAt:       time.Now(),
	}

	// Store in map
	mp := &ManagedProxy{
		Listener: proxy,
		Model:    proxyModel,
	}
	m.proxies[id] = mp

	// Start event forwarder to broadcast proxy events globally
	m.startEventForwarder(mp)

	// Add Health Check if configured
	if req.HealthCheck != nil && m.HealthCheck != nil {
		svc := config.Service{
			Address:     req.DefaultBackend,
			HealthCheck: convertHealthCheck(req.HealthCheck),
		}
		m.HealthCheck.AddService(id, svc)
	}

	// DB Persistence
	if m.db != nil {
		if _, err := m.db.Insert(proxyModel); err != nil {
			log.Printf("Failed to persist proxy to DB: %v\n", err)
		}
	}

	return &pb.CreateProxyResponse{
		Success: true,
		ProxyId: id,
	}, nil
}

func (m *ProxyManager) CreateProxy(req *pb.CreateProxyRequest) (*pb.CreateProxyResponse, error) {
	return m.CreateProxyWithID("", req)
}

// RemoveProxy completely removes a proxy (stop listener, delete from map and DB).
func (m *ProxyManager) RemoveProxy(id string) error {
	m.mu.Lock()
	defer m.mu.Unlock()

	mp, ok := m.proxies[id]
	if !ok {
		return nil // Already gone
	}

	// Stop event forwarder and listener
	m.stopEventForwarder(mp)
	if mp.Listener != nil {
		mp.Listener.Stop()
		mp.Listener = nil
	}

	// Stop health check
	if m.HealthCheck != nil {
		m.HealthCheck.RemoveService(id)
	}

	delete(m.proxies, id)

	// DB cleanup
	if m.db != nil {
		m.db.ID(id).Delete(new(ProxyModel))
	}

	return nil
}

func (m *ProxyManager) DisableProxy(id string) (*pb.DisableProxyResponse, error) {
	m.mu.Lock()
	defer m.mu.Unlock()

	// If ID is empty, disable all
	if id == "" {
		for pid, mp := range m.proxies {
			// Stop event forwarder before stopping listener
			m.stopEventForwarder(mp)

			if mp.Listener != nil {
				if err := mp.Listener.Stop(); err != nil {
					return &pb.DisableProxyResponse{
						Success:      false,
						ErrorMessage: fmt.Sprintf("Failed to disable proxy %s: %v", pid, err),
					}, nil
				}
				mp.Listener = nil
			}
			mp.Model.Enabled = false

			// Stop health check
			if m.HealthCheck != nil {
				m.HealthCheck.RemoveService(pid)
			}

			// DB Persistence
			if m.db != nil {
				if _, err := m.db.ID(pid).Cols("enabled").Update(&ProxyModel{Enabled: false}); err != nil {
					log.Printf("Failed to update proxy status in DB: %v\n", err)
				}
			}
		}
		return &pb.DisableProxyResponse{Success: true}, nil
	}

	mp, ok := m.proxies[id]
	if !ok {
		return &pb.DisableProxyResponse{
			Success:      false,
			ErrorMessage: "Proxy ID not found",
		}, nil
	}

	// Stop event forwarder before stopping listener
	m.stopEventForwarder(mp)

	if mp.Listener != nil {
		if err := mp.Listener.Stop(); err != nil {
			return &pb.DisableProxyResponse{
				Success:      false,
				ErrorMessage: fmt.Sprintf("Failed to disable proxy: %v", err),
			}, nil
		}
		mp.Listener = nil
	}

	mp.Model.Enabled = false

	// Stop health check
	if m.HealthCheck != nil {
		m.HealthCheck.RemoveService(id)
	}

	// DB Persistence
	if m.db != nil {
		if _, err := m.db.ID(id).Cols("enabled").Update(&ProxyModel{Enabled: false}); err != nil {
			log.Printf("Failed to update proxy status in DB: %v\n", err)
		}
	}

	return &pb.DisableProxyResponse{Success: true}, nil
}

// EnableProxy re-enables a disabled proxy
func (m *ProxyManager) EnableProxy(id string) (*pb.EnableProxyResponse, error) {
	m.mu.Lock()
	defer m.mu.Unlock()

	mp, ok := m.proxies[id]
	if !ok {
		return &pb.EnableProxyResponse{
			Success:      false,
			ErrorMessage: "Proxy ID not found",
		}, nil
	}

	// Check if listener exists and is actually running
	if mp.Listener != nil {
		status := mp.Listener.GetStatus()
		if status.Running {
			// Already running
			return &pb.EnableProxyResponse{Success: true}, nil
		}
		// Listener exists but not running (crashed or stopped), stop it and recreate
		m.stopEventForwarder(mp)
		mp.Listener.Stop()
		mp.Listener = nil
	}

	// Re-create listener from model
	model := mp.Model
	action := common.ActionType(model.DefaultAction)
	mockPreset := StringToMockPreset(model.DefaultMock)

	var proxy Listener
	switch m.mode {
	case ListenerModeFfi:
		fl := NewFfiListener(id, model.Name, model.ListenAddr, model.DefaultBackend, action, mockPreset, model.CertPEM, model.KeyPEM, model.CaPEM, pb.ClientAuthType(model.ClientAuthType), m.GeoIP)
		if m.Stats != nil {
			fl.SetStatsService(m.Stats)
		}
		fl.SetFallback(common.FallbackAction(model.FallbackAction), StringToMockPreset(model.FallbackMock))
		if m.GlobalRules != nil {
			fl.SetGlobalRules(m.GlobalRules)
		}
		if m.Approval != nil {
			fl.SetApprovalManager(m.Approval)
		}
		if m.NodeID != "" {
			fl.SetNodeID(m.NodeID)
		}
		proxy = fl

	case ListenerModeProcess:
		pl := NewProcessListener(id, model.Name, model.ListenAddr, model.DefaultBackend, action, mockPreset, model.CertPEM, model.KeyPEM, model.CaPEM, pb.ClientAuthType(model.ClientAuthType))
		pl.SetFallback(common.FallbackAction(model.FallbackAction), StringToMockPreset(model.FallbackMock))
		proxy = pl
	}

	if err := proxy.Start(); err != nil {
		return &pb.EnableProxyResponse{
			Success:      false,
			ErrorMessage: fmt.Sprintf("Failed to start listener: %v", err),
		}, nil
	}

	mp.Listener = proxy
	mp.Model.Enabled = true

	// Start event forwarder to broadcast proxy events globally
	m.startEventForwarder(mp)

	// DB Persistence
	if m.db != nil {
		if _, err := m.db.ID(id).Cols("enabled").Update(&ProxyModel{Enabled: true}); err != nil {
			log.Printf("Failed to update proxy status in DB: %v\n", err)
		}
	}

	return &pb.EnableProxyResponse{Success: true}, nil
}

// UpdateProxy updates proxy configuration
func (m *ProxyManager) UpdateProxy(req *pb.UpdateProxyRequest) (*pb.UpdateProxyResponse, error) {
	m.mu.Lock()
	defer m.mu.Unlock()

	mp, ok := m.proxies[req.ProxyId]
	if !ok {
		return &pb.UpdateProxyResponse{
			Success:      false,
			ErrorMessage: "Proxy ID not found",
		}, nil
	}

	// Update model fields if provided
	if req.ListenAddr != "" {
		mp.Model.ListenAddr = req.ListenAddr
	}
	if req.DefaultBackend != "" {
		mp.Model.DefaultBackend = req.DefaultBackend
	}
	if req.DefaultAction != common.ActionType_ACTION_TYPE_UNSPECIFIED {
		mp.Model.DefaultAction = int(req.DefaultAction)
	}
	if req.DefaultMock != common.MockPreset_MOCK_PRESET_UNSPECIFIED {
		mp.Model.DefaultMock = MockPresetToString(req.DefaultMock)
	}

	// Note: To apply listen address change, proxy needs to be restarted
	needsRestart := req.ListenAddr != "" && mp.Listener != nil

	// Update DB
	if m.db != nil {
		if _, err := m.db.ID(req.ProxyId).Update(mp.Model); err != nil {
			return &pb.UpdateProxyResponse{
				Success:      false,
				ErrorMessage: fmt.Sprintf("Failed to update DB: %v", err),
			}, nil
		}
	}

	_ = needsRestart // Note: Caller should restart if listen_addr changed
	return &pb.UpdateProxyResponse{
		Success: true,
	}, nil
}

// RestartListeners stops and restarts all active listeners
func (m *ProxyManager) RestartListeners() (*pb.RestartListenersResponse, error) {
	m.mu.Lock()
	defer m.mu.Unlock()

	restartedCount := int32(0)

	for pid, mp := range m.proxies {
		if mp.Listener == nil || !mp.Model.Enabled {
			continue
		}

		// Stop event forwarder before stopping listener
		m.stopEventForwarder(mp)

		// Stop listener
		if err := mp.Listener.Stop(); err != nil {
			log.Printf("Failed to stop listener %s: %v", pid, err)
			continue
		}

		// Re-create listener
		model := mp.Model
		action := common.ActionType(model.DefaultAction)
		mockPreset := StringToMockPreset(model.DefaultMock)

		var proxy Listener
		switch m.mode {
		case ListenerModeFfi:
			fl := NewFfiListener(pid, model.Name, model.ListenAddr, model.DefaultBackend, action, mockPreset, model.CertPEM, model.KeyPEM, model.CaPEM, pb.ClientAuthType(model.ClientAuthType), m.GeoIP)
			if m.Stats != nil {
				fl.SetStatsService(m.Stats)
			}
			fl.SetFallback(common.FallbackAction(model.FallbackAction), StringToMockPreset(model.FallbackMock))
			if m.GlobalRules != nil {
				fl.SetGlobalRules(m.GlobalRules)
			}
			if m.Approval != nil {
				fl.SetApprovalManager(m.Approval)
			}
			if m.NodeID != "" {
				fl.SetNodeID(m.NodeID)
			}
			proxy = fl

		case ListenerModeProcess:
			pl := NewProcessListener(pid, model.Name, model.ListenAddr, model.DefaultBackend, action, mockPreset, model.CertPEM, model.KeyPEM, model.CaPEM, pb.ClientAuthType(model.ClientAuthType))
			pl.SetFallback(common.FallbackAction(model.FallbackAction), StringToMockPreset(model.FallbackMock))
			proxy = pl
		}

		if err := proxy.Start(); err != nil {
			log.Printf("Failed to restart listener %s: %v", pid, err)
			continue
		}

		mp.Listener = proxy

		// Start event forwarder for new listener
		m.startEventForwarder(mp)

		restartedCount++
	}

	return &pb.RestartListenersResponse{
		Success:        true,
		RestartedCount: restartedCount,
	}, nil
}

// ReloadRules replaces rules for a proxy
func (m *ProxyManager) ReloadRules(proxyID string, rules []*pb.Rule) (*pb.ReloadRulesResponse, error) {
	m.mu.Lock()
	mp, ok := m.proxies[proxyID]
	m.mu.Unlock()

	if !ok {
		return &pb.ReloadRulesResponse{
			Success:      false,
			ErrorMessage: "Proxy ID not found",
		}, nil
	}

	if mp.Listener == nil {
		return &pb.ReloadRulesResponse{
			Success:      false,
			ErrorMessage: "Proxy not running",
		}, nil
	}

	// Get current rules and remove them
	currentRules := mp.Listener.GetRules()
	for _, r := range currentRules {
		mp.Listener.RemoveRule(r.Id)
	}

	// Add new rules
	rulesLoaded := int32(0)
	for _, rule := range rules {
		mp.Listener.AddRule(rule)
		rulesLoaded++
	}

	// Update DB
	if m.db != nil {
		// Delete old rules
		m.db.Where("proxy_id = ?", proxyID).Delete(&RuleModel{})

		// Insert new rules
		for _, rule := range rules {
			condBytes, _ := json.Marshal(rule.Conditions)
			mockBytes, _ := json.Marshal(rule.MockResponse)

			ruleModel := &RuleModel{
				ID:             rule.Id,
				ProxyID:        proxyID,
				Name:           rule.Name,
				Priority:       int(rule.Priority),
				Enabled:        rule.Enabled,
				Action:         int(rule.Action),
				TargetBackend:  rule.TargetBackend,
				ConditionsJSON: string(condBytes),
				MockConfigJSON: string(mockBytes),
				Expression:     rule.Expression,
			}
			if _, err := m.db.Insert(ruleModel); err != nil {
				log.Printf("Failed to save rule to DB: %v", err)
			}
		}
	}

	return &pb.ReloadRulesResponse{
		Success:     true,
		RulesLoaded: rulesLoaded,
	}, nil
}

// StopAllListeners stops all active listeners
func (m *ProxyManager) StopAllListeners() {
	m.mu.Lock()
	defer m.mu.Unlock()

	for pid, mp := range m.proxies {
		// Stop event forwarder before stopping listener
		m.stopEventForwarder(mp)

		if mp.Listener != nil {
			if err := mp.Listener.Stop(); err != nil {
				log.Printf("Failed to stop listener %s: %v", mp.Model.Name, err)
			}
			mp.Listener = nil
		}
		// Stop health checks
		if m.HealthCheck != nil {
			m.HealthCheck.RemoveService(pid)
		}
	}
	m.proxies = make(map[string]*ManagedProxy)
}

// Close shuts down the proxy manager and releases all resources.
func (m *ProxyManager) Close() {
	m.StopAllListeners()

	if m.HealthCheck != nil {
		m.HealthCheck.Stop()
	}

	if m.GeoIP != nil {
		m.GeoIP.Close()
	}

	if m.db != nil {
		m.db.Close()
	}
}

func (m *ProxyManager) GetStatus(id string) (*pb.ProxyStatus, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if id == "" {
		return nil, fmt.Errorf("id is required for GetStatus")
	}

	mp, ok := m.proxies[id]
	if !ok {
		return nil, fmt.Errorf("proxy not found")
	}

	var status *pb.ProxyStatus
	if mp.Listener != nil {
		status = mp.Listener.GetStatus()
	} else {
		status = &pb.ProxyStatus{
			ProxyId:        mp.Model.ID,
			Running:        false,
			ListenAddr:     mp.Model.ListenAddr,
			DefaultBackend: mp.Model.DefaultBackend,
			DefaultAction:  common.ActionType(mp.Model.DefaultAction),
			DefaultMock:    StringToMockPreset(mp.Model.DefaultMock),
			FallbackAction: common.FallbackAction(mp.Model.FallbackAction),
			FallbackMock:   StringToMockPreset(mp.Model.FallbackMock),
		}
	}

	// Add HealthCheck info
	if mp.Model.HealthCheckJSON != "" {
		var hc pb.HealthCheckConfig
		if err := json.Unmarshal([]byte(mp.Model.HealthCheckJSON), &hc); err == nil {
			status.HealthCheck = &hc

			// Populate Status
			if m.HealthCheck != nil {
				healthy, exists := m.HealthCheck.GetStatus(id)
				if exists {
					if healthy {
						status.HealthStatus = pb.HealthStatus_HEALTH_STATUS_HEALTHY
					} else {
						status.HealthStatus = pb.HealthStatus_HEALTH_STATUS_UNHEALTHY
					}
				} else {
					status.HealthStatus = pb.HealthStatus_HEALTH_STATUS_UNKNOWN
				}
			}
		}
	}

	return status, nil
}

// GetAllStatuses returns status of all managed proxies
func (m *ProxyManager) GetAllStatuses() []*pb.ProxyStatus {
	m.mu.RLock()
	defer m.mu.RUnlock()

	statuses := make([]*pb.ProxyStatus, 0, len(m.proxies))
	for _, mp := range m.proxies {
		var st *pb.ProxyStatus
		if mp.Listener != nil {
			st = mp.Listener.GetStatus()
		} else {
			st = &pb.ProxyStatus{
				ProxyId:        mp.Model.ID,
				Running:        false,
				ListenAddr:     mp.Model.ListenAddr,
				DefaultBackend: mp.Model.DefaultBackend,
				DefaultAction:  common.ActionType(mp.Model.DefaultAction),
				DefaultMock:    StringToMockPreset(mp.Model.DefaultMock),
				FallbackAction: common.FallbackAction(mp.Model.FallbackAction),
				FallbackMock:   StringToMockPreset(mp.Model.FallbackMock),
			}
		}

		if mp.Model.HealthCheckJSON != "" {
			var hc pb.HealthCheckConfig
			if err := json.Unmarshal([]byte(mp.Model.HealthCheckJSON), &hc); err == nil {
				st.HealthCheck = &hc

				// Populate Status
				if m.HealthCheck != nil {
					healthy, exists := m.HealthCheck.GetStatus(mp.Model.ID)
					if exists {
						if healthy {
							st.HealthStatus = pb.HealthStatus_HEALTH_STATUS_HEALTHY
						} else {
							st.HealthStatus = pb.HealthStatus_HEALTH_STATUS_UNHEALTHY
						}
					} else {
						st.HealthStatus = pb.HealthStatus_HEALTH_STATUS_UNKNOWN
					}
				}
			}
		}

		statuses = append(statuses, st)
	}
	return statuses
}

func (m *ProxyManager) AddRule(req *pb.AddRuleRequest) (*pb.Rule, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	mp, ok := m.proxies[req.ProxyId]
	if !ok {
		return nil, fmt.Errorf("proxy not found")
	}

	if req.Rule.Id == "" {
		req.Rule.Id = uuid.New().String()
	}

	if mp.Listener != nil {
		mp.Listener.AddRule(req.Rule)
	}

	if m.db != nil {
		condBytes, _ := json.Marshal(req.Rule.Conditions)
		mockBytes, _ := json.Marshal(req.Rule.MockResponse)

		ruleModel := &RuleModel{
			ID:             req.Rule.Id,
			ProxyID:        req.ProxyId,
			Name:           req.Rule.Name,
			Priority:       int(req.Rule.Priority),
			Enabled:        req.Rule.Enabled,
			Action:         int(req.Rule.Action),
			TargetBackend:  req.Rule.TargetBackend,
			ConditionsJSON: string(condBytes),
			MockConfigJSON: string(mockBytes),
			Expression:     req.Rule.Expression,
			CreatedAt:      time.Now(),
			UpdatedAt:      time.Now(),
		}

		if _, err := m.db.Insert(ruleModel); err != nil {
			log.Printf("Failed to persist rule to DB: %v\n", err)
		}
	}

	return req.Rule, nil
}

func (m *ProxyManager) RemoveRule(req *pb.RemoveRuleRequest) error {
	m.mu.RLock()
	defer m.mu.RUnlock()

	mp, ok := m.proxies[req.ProxyId]
	if !ok {
		return fmt.Errorf("proxy not found")
	}

	if mp.Listener != nil {
		if err := mp.Listener.RemoveRule(req.RuleId); err != nil {
			return err
		}
	}

	if m.db != nil {
		if _, err := m.db.Delete(&RuleModel{ID: req.RuleId}); err != nil {
			log.Printf("Failed to delete rule from DB: %v\n", err)
		}
	}

	return nil
}

func (m *ProxyManager) GetRules(proxyID string) ([]*pb.Rule, error) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	mp, ok := m.proxies[proxyID]
	if !ok {
		return nil, fmt.Errorf("proxy not found")
	}

	if mp.Listener != nil {
		return mp.Listener.GetRules(), nil
	}

	if m.db != nil {
		var rules []RuleModel
		if err := m.db.Where("proxy_id = ?", proxyID).Find(&rules); err != nil {
			return nil, err
		}

		var pbRules []*pb.Rule
		for _, r := range rules {
			pbRules = append(pbRules, &pb.Rule{
				Id:            r.ID,
				Name:          r.Name,
				Priority:      int32(r.Priority),
				Enabled:       r.Enabled,
				Action:        common.ActionType(r.Action),
				TargetBackend: r.TargetBackend,
				Expression:    r.Expression,
			})
		}
		return pbRules, nil
	}
	return nil, nil
}

// Connection Management

func (m *ProxyManager) GetConnectionBytes(proxyID, connID string) (in, out int64) {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if proxy, ok := m.proxies[proxyID]; ok && proxy.Listener != nil {
		if i, o, ok := proxy.Listener.GetConnectionBytes(connID); ok {
			return i, o
		}
	}
	return 0, 0
}

func (m *ProxyManager) GetActiveConnections(proxyID string) []*ConnectionMetadata {
	m.mu.RLock()
	defer m.mu.RUnlock()

	// If proxyID is specified, return connections for that proxy only
	if proxyID != "" {
		if proxy, ok := m.proxies[proxyID]; ok && proxy.Listener != nil {
			return proxy.Listener.GetActiveConnections()
		}
		return nil
	}

	// If no proxyID, return connections from all proxies
	var all []*ConnectionMetadata
	for _, proxy := range m.proxies {
		if proxy.Listener != nil {
			conns := proxy.Listener.GetActiveConnections()
			all = append(all, conns...)
		}
	}
	return all
}

func (m *ProxyManager) CloseConnection(proxyID, connID string) error {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if proxyID != "" {
		if proxy, ok := m.proxies[proxyID]; ok && proxy.Listener != nil {
			return proxy.Listener.CloseConnection(proxyID, connID)
		}
		return fmt.Errorf("proxy not found")
	}

	// Search all proxies for the connection
	for pid, proxy := range m.proxies {
		if proxy.Listener != nil {
			if err := proxy.Listener.CloseConnection(pid, connID); err == nil {
				return nil
			}
		}
	}
	return fmt.Errorf("connection not found: %s", connID)
}

func (m *ProxyManager) CloseAllConnections(proxyID string) error {
	m.mu.RLock()
	defer m.mu.RUnlock()

	if proxyID != "" {
		if proxy, ok := m.proxies[proxyID]; ok && proxy.Listener != nil {
			return proxy.Listener.CloseAllConnections()
		}
		return fmt.Errorf("proxy not found")
	}

	// Close all connections on all proxies
	for _, proxy := range m.proxies {
		if proxy.Listener != nil {
			proxy.Listener.CloseAllConnections()
		}
	}
	return nil
}

func (m *ProxyManager) ConfigureGeoIP(req *pb.ConfigureGeoIPRequest) (*pb.ConfigureGeoIPResponse, error) {
	// Create a new geoip.Manager for runtime configuration
	manager := geoip.NewManager()

	if req.Mode == pb.ConfigureGeoIPRequest_MODE_LOCAL_DB {
		if err := manager.SetLocalDB(req.CityDbPath, req.IspDbPath); err != nil {
			return &pb.ConfigureGeoIPResponse{
				Success: false,
				Error:   fmt.Sprintf("Failed to load local DB: %v", err),
			}, nil
		}
		manager.SetStrategy([]string{"l1", "local"})
	} else {
		providerList := strings.Split(req.Provider, ",")
		for _, pURL := range providerList {
			pURL = strings.TrimSpace(pURL)
			if pURL == "" {
				continue
			}

			name := "custom"
			if strings.Contains(pURL, "ip-api") {
				name = "ip-api"
			}
			if strings.Contains(pURL, "ipinfo") {
				name = "ipinfo"
			}
			manager.AddRemoteProvider(name, pURL)
		}

		if len(providerList) == 0 {
			manager.AddRemoteProvider("default", "https://ip-api.com/json/%s")
		}
		manager.SetStrategy([]string{"l1", "remote"})
	}

	// Create embedded client from the new manager
	client := geoip.NewEmbeddedClient(manager)
	m.GeoIP.SetClient(client)

	return &pb.ConfigureGeoIPResponse{Success: true}, nil
}

func (m *ProxyManager) LookupIP(req *pb.LookupIPRequest) (*pb.LookupIPResponse, error) {
	if m.GeoIP == nil {
		return &pb.LookupIPResponse{}, nil
	}

	start := time.Now()
	info := m.GeoIP.Lookup(req.Ip)
	elapsed := time.Since(start).Milliseconds()

	return &pb.LookupIPResponse{
		Geo:          info,
		Cached:       elapsed < 5, // If very fast, likely cached
		LookupTimeMs: elapsed,
	}, nil
}

func (m *ProxyManager) GetGeoIPStatus(req *pb.GetGeoIPStatusRequest) (*pb.GetGeoIPStatusResponse, error) {
	resp := &pb.GetGeoIPStatusResponse{
		Enabled: m.GeoIP != nil,
		Mode:    "disabled",
	}

	if m.GeoIP != nil {
		// The GeoIP service is enabled
		// We can't easily get internal state, so return basic info
		resp.Mode = "embedded" // FFI or embedded mode
		resp.Strategy = []string{"l1", "l2", "local", "remote"}
	}

	return resp, nil
}

func (m *ProxyManager) LoadConfig() error {
	if m.ConfigPath == "" {
		return nil
	}

	file, err := os.Open(m.ConfigPath)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}
	defer file.Close()

	var cfg config.YAMLConfig
	if err := yaml.NewDecoder(file).Decode(&cfg); err != nil {
		return err
	}

	m.mu.Lock()
	defer m.mu.Unlock()

	if len(cfg.TCP.Services) > 0 {
		// Stop old checks
		m.HealthCheck.Stop()
		m.HealthCheck = health.NewHealthChecker(cfg.TCP.Services)
		m.HealthCheck.Start()
	}

	for name, ep := range cfg.EntryPoints {
		id := uuid.New().String()

		var actionVal common.ActionType = common.ActionType_ACTION_TYPE_BLOCK
		if ep.DefaultAction == "allow" {
			actionVal = common.ActionType_ACTION_TYPE_ALLOW
		}
		if ep.DefaultAction == "mock" {
			actionVal = common.ActionType_ACTION_TYPE_MOCK
		}

		defaultMockVal := StringToMockPreset(ep.DefaultMock)

		proxy := NewEmbeddedListener(id, name, ep.Address, ep.DefaultBackend, actionVal, defaultMockVal, "", "", "", pb.ClientAuthType_CLIENT_AUTH_AUTO, m.GeoIP)

		if err := proxy.Start(); err != nil {
			log.Printf("Failed to start loaded proxy %s: %v\n", name, err)
			continue
		}

		mp := &ManagedProxy{
			Listener: proxy,
			Model: &ProxyModel{
				ID:             id,
				Name:           name,
				ListenAddr:     ep.Address,
				DefaultBackend: ep.DefaultBackend,
				DefaultAction:  int(actionVal),
				DefaultMock:    ep.DefaultMock,
				Enabled:        true,
			},
		}

		m.proxies[id] = mp

		// Start event forwarder to broadcast proxy events globally
		m.startEventForwarder(mp)
	}
	return nil
}

func (m *ProxyManager) InitDB(dbPath string) error {
	var err error
	if err := os.MkdirAll(filepath.Dir(dbPath), 0755); err != nil {
		return fmt.Errorf("failed to create db dir: %w", err)
	}

	m.db, err = xorm.NewEngine("sqlite3", dbPath)
	if err != nil {
		return fmt.Errorf("failed to create xorm engine: %w", err)
	}

	if err := m.db.Sync2(new(ProxyModel), new(RuleModel)); err != nil {
		return fmt.Errorf("failed to sync schema: %w", err)
	}

	return m.LoadState()
}

func (m *ProxyManager) LoadState() error {
	if m.db == nil {
		return nil
	}

	var proxies []ProxyModel
	if err := m.db.Find(&proxies); err != nil {
		return err
	}

	for _, p := range proxies {
		if !p.Enabled {
			continue
		}

		action := common.ActionType(p.DefaultAction)
		mockPreset := StringToMockPreset(p.DefaultMock)

		proxy := NewEmbeddedListener(p.ID, p.Name, p.ListenAddr, p.DefaultBackend, action, mockPreset, p.CertPEM, p.KeyPEM, p.CaPEM, pb.ClientAuthType(p.ClientAuthType), m.GeoIP)

		if m.Stats != nil {
			proxy.SetStatsService(m.Stats)
		}
		proxy.SetFallback(common.FallbackAction(p.FallbackAction), StringToMockPreset(p.FallbackMock))
		// Wire global rules and approval
		if m.GlobalRules != nil {
			proxy.SetGlobalRules(m.GlobalRules)
		}
		if m.Approval != nil {
			proxy.SetApprovalManager(m.Approval)
		}
		if m.NodeID != "" {
			proxy.SetNodeID(m.NodeID)
		}

		if err := proxy.Start(); err != nil {
			log.Printf("Failed to restore proxy %s: %v\n", p.Name, err)
			continue
		}

		// Load rules
		var rules []RuleModel
		if err := m.db.Where("proxy_id = ?", p.ID).Find(&rules); err != nil {
			log.Printf("Failed to load rules for proxy %s: %v\n", p.Name, err)
		} else {
			for _, r := range rules {
				var conds []*pb.Condition
				if r.ConditionsJSON != "" {
					if err := json.Unmarshal([]byte(r.ConditionsJSON), &conds); err != nil {
						log.Printf("Warning: Failed to parse conditions for rule %s: %v", r.ID, err)
					}
				}

				var mockCfg pb.MockConfig
				if r.MockConfigJSON != "" {
					if err := json.Unmarshal([]byte(r.MockConfigJSON), &mockCfg); err != nil {
						log.Printf("Warning: Failed to parse mock config for rule %s: %v", r.ID, err)
					}
				}

				rule := &pb.Rule{
					Id:            r.ID,
					Name:          r.Name,
					Priority:      int32(r.Priority),
					Enabled:       r.Enabled,
					Action:        common.ActionType(r.Action),
					TargetBackend: r.TargetBackend,
					Conditions:    conds,
					MockResponse:  &mockCfg,
					Expression:    r.Expression,
				}
				proxy.AddRule(rule)
			}
		}

		// Copy loop variable to avoid capture bug (Go < 1.22)
		pCopy := p
		mp := &ManagedProxy{
			Listener: proxy,
			Model:    &pCopy,
		}
		m.proxies[p.ID] = mp

		// Start event forwarder to broadcast proxy events globally
		m.startEventForwarder(mp)
	}

	return nil
}
