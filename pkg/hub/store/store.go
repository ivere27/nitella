package store

import (
	"errors"
	"fmt"
	"time"

	_ "github.com/go-sql-driver/mysql" // MySQL driver
	"github.com/ivere27/nitella/pkg/hub/model"
	_ "github.com/lib/pq"              // PostgreSQL driver
	_ "github.com/mattn/go-sqlite3"    // SQLite driver

	"xorm.io/xorm"
)

// SECURITY NOTE: Zero-Trust Architecture
//
// Sensitive data is E2E encrypted with user's public key BEFORE reaching Hub:
//   - Node.EncryptedMetadata (name, IP, ports)
//   - User.EncryptedProfile (email, avatar)
//   - EncryptedMetric.EncryptedBlob (metrics data)
//   - ProxyRevision.EncryptedBlob (proxy configuration)
//   - ApprovalRequest.EncryptedPayload (source IP, dest, details)
//   - AuditLog.EncryptedPayload (event type, content)
//
// Hub stores encrypted blobs and routes by blind RoutingToken (HMAC).
// Hub CANNOT decrypt user data - it's a blind relay.
//
// For defense-in-depth, use database-level encryption (SQLCipher, TDE)
// or encrypted storage (LUKS, EBS encryption) in production.

// All model structs are defined in model package - no duplicates here

// Store defines the persistence interface for the Hub
type Store interface {
	// Registration
	SaveRegistrationRequest(req *model.RegistrationRequest) error
	GetRegistrationRequest(code string) (*model.RegistrationRequest, error)
	DeleteRegistrationRequest(code string) error
	// ApproveRegistration atomically approves a pending registration (optimistic locking)
	ApproveRegistration(code, certPEM, caPEM, routingToken string) (*model.RegistrationRequest, error)
	// ApproveNodeAtomic atomically approves registration, saves node, and saves routing token info.
	// All three operations succeed together or none do (prevents billing bypass on partial failure).
	ApproveNodeAtomic(code, certPEM, caPEM, routingToken string, node *model.Node, info *model.RoutingTokenInfo) (*model.RegistrationRequest, error)
	// GetApprovedCLICAs returns all unique CLI CA PEMs from approved registrations
	GetApprovedCLICAs() ([]string, error)

	// Nodes (Zero-Trust: no owner lookups)
	SaveNode(node *model.Node) error
	GetNode(id string) (*model.Node, error)
	GetNodeByRoutingToken(routingToken string) (*model.Node, error)
	ListNodes() ([]*model.Node, error)
	CountNodes() (total int64, online int64, err error) // count without loading all
	UpdateNodeStatus(id string, status string) error
	DeleteNode(id string) error

	// Routing Tokens (Blind Routing)
	SaveRoutingTokenInfo(info *model.RoutingTokenInfo) error
	GetRoutingTokenInfo(routingToken string) (*model.RoutingTokenInfo, error)
	UpdateRoutingTokenTier(routingToken, tier string) error
	UpdateTierByLicenseKey(licenseKey, tier string) error // Bulk update for billing
	DeleteRoutingTokenInfo(routingToken string) error

	// Encrypted Metrics (Zero-Trust: Hub stores encrypted blobs only)
	SaveEncryptedMetric(metric *model.EncryptedMetric) error
	GetEncryptedMetricsHistory(routingToken string, start, end time.Time, limit int) ([]*model.EncryptedMetric, error)
	DeleteOldMetrics(before time.Time) error

	// Encrypted Logs (Zero-Trust: Hub stores encrypted blobs only)
	SaveEncryptedLog(log *model.EncryptedLog) error
	GetEncryptedLogsHistory(routingToken string, start, end time.Time, limit int) ([]*model.EncryptedLog, error)
	GetEncryptedLogsByNode(routingToken, nodeID string, start, end time.Time, limit, offset int) ([]*model.EncryptedLog, error)
	CountLogs(routingToken string) (int64, error)
	CountAllLogs() (int64, error)
	GetLogsStatsByRoutingToken() (map[string]int64, error)
	GetLogStorageByRoutingToken() (map[string]int64, error)
	GetOldestAndNewestLog() (oldest, newest time.Time, err error)
	DeleteOldLogs(before time.Time) error
	DeleteOldestLogs(routingToken string, keepCount int) error
	DeleteLogsByRoutingToken(routingToken string) (int64, error)
	DeleteLogsByNodeID(routingToken, nodeID string) (int64, error)
	DeleteLogsBefore(routingToken string, before time.Time) (int64, error)

	// Users (kept for backward compatibility, will be phased out)
	SaveUser(user *model.User) error
	GetUser(id string) (*model.User, error)
	GetUserByBlindIndex(index string) (*model.User, error)
	UpdateUserTier(userID, tier string) error
	ListUsers() ([]*model.User, error)
	CountUsers() (int64, error) // count without loading all
	DeleteUser(id string) error

	// FCM (Zero-Trust: by FCMTopic, not UserID)
	SaveFCMToken(token *model.FCMToken) error
	GetFCMTokensByTopic(fcmTopic string) ([]*model.FCMToken, error)
	DeleteFCMToken(token string) error

	// Pairing Tokens
	SavePairingToken(token *model.PairingToken) error
	GetPairingToken(userID string) (*model.PairingToken, error)

	// Certificate Revocation (Zero-Trust: by RoutingToken)
	SaveRevocation(rev *model.CertificateRevocation) error
	IsRevoked(serialNumber string) (bool, error)
	IsRevokedByNodeID(nodeID string) (bool, error)
	IsRevokedByFingerprint(fingerprint string) (bool, error)
	ListRevocationsByRoutingToken(routingToken string) ([]*model.CertificateRevocation, error)
	GetAllRevocations() ([]*model.CertificateRevocation, error)

	// Invite Codes
	GetInviteCode(code string) (*model.InviteCode, error)
	SaveInviteCode(code *model.InviteCode) error
	DeleteInviteCode(code string) error
	IncrementInviteCodeUsage(code string) error
	ConsumeInviteCode(code string) error // Atomic check-and-increment
	CountInviteCodeUsage(code string) (int64, error)
	ListActiveInviteCodes() ([]*model.InviteCode, error)

	// ProxyConfig (Zero-Trust: metadata only, content is encrypted in revisions)
	CreateProxyConfig(cfg *model.ProxyConfig) error
	GetProxyConfig(proxyID string) (*model.ProxyConfig, error)
	GetProxyConfigByRoutingToken(routingToken string) (*model.ProxyConfig, error)
	ListProxyConfigsByRoutingToken(routingToken string) ([]*model.ProxyConfig, error)
	CountProxyConfigsByRoutingToken(routingToken string) (int64, error)
	DeleteProxyConfig(proxyID string) error // Soft delete

	// ProxyRevision (Zero-Trust: encrypted content)
	CreateProxyRevision(rev *model.ProxyRevision) error
	GetProxyRevision(proxyID string, revisionNum int64) (*model.ProxyRevision, error)
	GetLatestProxyRevision(proxyID string) (*model.ProxyRevision, error)
	ListProxyRevisions(proxyID string) ([]*model.ProxyRevision, error)
	CountProxyRevisions(proxyID string) (int64, error)
	DeleteProxyRevision(id int64) error
	DeleteOldestProxyRevisions(proxyID string, keepCount int) (int64, error) // Returns deleted count
	GetTotalProxyStorageByRoutingToken(routingToken string) (int64, error)    // Total bytes across all proxies

	// Approval Requests (Zero-Trust: by RoutingToken)
	SaveApprovalRequest(req *model.ApprovalRequest) error
	GetApprovalRequest(id string) (*model.ApprovalRequest, error)
	ListPendingApprovalsByRoutingToken(routingToken string) ([]*model.ApprovalRequest, error)
	UpdateApprovalStatus(id, status string) error

	// Audit Logs (Zero-Trust: encrypted)
	SaveAuditLog(log *model.AuditLog) error
	GetAuditLogs(routingToken string, limit int) ([]*model.AuditLog, error)
	CountAuditLogs(routingToken string) (int64, error)
	DeleteExpiredAuditLogs() error
	DeleteOldestAuditLog(routingToken string) error

	// Lifecycle
	Close() error
}

// XORMStore implements Store using XORM (supports SQLite, MySQL, Postgres)
type XORMStore struct {
	engine *xorm.Engine
}

// DB returns the underlying xorm engine
func (s *XORMStore) DB() *xorm.Engine {
	return s.engine
}

// NewStore creates a new Store based on driver and DSN
func NewStore(driver, dsn string) (Store, error) {
	engine, err := xorm.NewEngine(driver, dsn)
	if err != nil {
		return nil, fmt.Errorf("failed to create engine: %w", err)
	}

	// Sync all tables
	if err := engine.Sync(
		new(model.Node),
		new(model.RegistrationRequest),
		new(model.EncryptedMetric),
		new(model.EncryptedLog),
		new(model.User),
		new(model.FCMToken),
		new(model.RoutingTokenInfo),
		new(model.PairingToken),
		new(model.CertificateRevocation),
		new(model.InviteCode),
		new(model.ProxyConfig),
		new(model.ProxyRevision),
		new(model.ApprovalRequest),
		new(model.AuditLog),
	); err != nil {
		return nil, fmt.Errorf("db sync failed: %w", err)
	}

	return &XORMStore{engine: engine}, nil
}

// NewSQLiteStore creates a new SQLite-backed store
func NewSQLiteStore(dbPath string) (*XORMStore, error) {
	s, err := NewStore("sqlite3", dbPath)
	if err != nil {
		return nil, err
	}
	return s.(*XORMStore), nil
}

// Registration methods

func (s *XORMStore) SaveRegistrationRequest(req *model.RegistrationRequest) error {
	exist, err := s.engine.Exist(&model.RegistrationRequest{Code: req.Code})
	if err != nil {
		return err
	}
	if exist {
		_, err = s.engine.ID(req.Code).Update(req)
	} else {
		_, err = s.engine.Insert(req)
	}
	return err
}

func (s *XORMStore) GetRegistrationRequest(code string) (*model.RegistrationRequest, error) {
	req := &model.RegistrationRequest{Code: code}
	has, err := s.engine.Get(req)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("registration request not found")
	}
	return req, nil
}

func (s *XORMStore) DeleteRegistrationRequest(code string) error {
	_, err := s.engine.Delete(&model.RegistrationRequest{Code: code})
	return err
}

// ApproveRegistration atomically approves a pending registration using optimistic locking.
// Returns error if already approved, expired, or not found.
func (s *XORMStore) ApproveRegistration(code, certPEM, caPEM, routingToken string) (*model.RegistrationRequest, error) {
	req := &model.RegistrationRequest{Code: code}
	has, err := s.engine.Get(req)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("registration not found")
	}

	// Check if already approved
	if req.Status == "APPROVED" {
		return nil, errors.New("registration already approved")
	}

	// Check if expired
	if req.Status == "REJECTED" {
		return nil, errors.New("registration was rejected")
	}

	// Update fields
	req.Status = "APPROVED"
	req.CertPEM = certPEM
	req.CaPEM = caPEM
	req.RoutingToken = routingToken

	// Optimistic locking: XORM auto-adds WHERE version=? due to `xorm:"version"` tag
	// If another request modified the row, affected will be 0
	affected, err := s.engine.ID(code).Update(req)
	if err != nil {
		return nil, err
	}
	if affected == 0 {
		return nil, errors.New("registration was modified by another request")
	}

	return req, nil
}

// ApproveNodeAtomic atomically approves registration, saves node, and saves routing token info.
// All three operations succeed together or none do (prevents billing bypass on partial failure).
func (s *XORMStore) ApproveNodeAtomic(code, certPEM, caPEM, routingToken string, node *model.Node, info *model.RoutingTokenInfo) (*model.RegistrationRequest, error) {
	session := s.engine.NewSession()
	defer session.Close()

	if err := session.Begin(); err != nil {
		return nil, err
	}

	// Step 1: Approve registration
	req := &model.RegistrationRequest{Code: code}
	has, err := session.Get(req)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("registration not found")
	}
	if req.Status == "APPROVED" {
		return nil, errors.New("registration already approved")
	}
	if req.Status == "REJECTED" {
		return nil, errors.New("registration was rejected")
	}

	req.Status = "APPROVED"
	req.CertPEM = certPEM
	req.CaPEM = caPEM
	req.RoutingToken = routingToken

	affected, err := session.ID(code).Update(req)
	if err != nil {
		return nil, err
	}
	if affected == 0 {
		return nil, errors.New("registration was modified by another request")
	}

	// Step 2: Save node
	if _, err := session.Insert(node); err != nil {
		return nil, fmt.Errorf("failed to save node: %w", err)
	}

	// Step 3: Save routing token info
	if info != nil {
		if _, err := session.Insert(info); err != nil {
			return nil, fmt.Errorf("failed to save routing token info: %w", err)
		}
	}

	if err := session.Commit(); err != nil {
		return nil, err
	}

	return req, nil
}

// GetApprovedCLICAs returns all unique CLI CA PEMs from approved registrations
func (s *XORMStore) GetApprovedCLICAs() ([]string, error) {
	var reqs []model.RegistrationRequest
	// Use struct field conditions for XORM compatibility
	err := s.engine.Where("status = ?", "APPROVED").Find(&reqs)
	if err != nil {
		return nil, err
	}

	// Deduplicate CA PEMs
	seen := make(map[string]bool)
	var cas []string
	for _, req := range reqs {
		if req.CaPEM != "" && !seen[req.CaPEM] {
			seen[req.CaPEM] = true
			cas = append(cas, req.CaPEM)
		}
	}
	return cas, nil
}

// Node methods

func (s *XORMStore) SaveNode(node *model.Node) error {
	exist, err := s.engine.Exist(&model.Node{ID: node.ID})
	if err != nil {
		return err
	}
	if exist {
		_, err = s.engine.ID(node.ID).Update(node)
	} else {
		_, err = s.engine.Insert(node)
	}
	return err
}

func (s *XORMStore) GetNode(id string) (*model.Node, error) {
	node := &model.Node{ID: id}
	has, err := s.engine.Get(node)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("node not found")
	}
	return node, nil
}

func (s *XORMStore) GetNodeByRoutingToken(routingToken string) (*model.Node, error) {
	node := &model.Node{}
	has, err := s.engine.Where("routing_token = ?", routingToken).Get(node)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("node not found")
	}
	return node, nil
}

func (s *XORMStore) ListNodes() ([]*model.Node, error) {
	var nodes []*model.Node
	err := s.engine.Find(&nodes)
	return nodes, err
}

func (s *XORMStore) UpdateNodeStatus(id string, status string) error {
	node := &model.Node{
		Status:   status,
		LastSeen: time.Now(),
	}
	_, err := s.engine.ID(id).Cols("status", "last_seen").Update(node)
	return err
}

func (s *XORMStore) DeleteNode(id string) error {
	_, err := s.engine.Delete(&model.Node{ID: id})
	return err
}

// CountNodes returns total and online node counts (efficient counting)
func (s *XORMStore) CountNodes() (total int64, online int64, err error) {
	total, err = s.engine.Count(&model.Node{})
	if err != nil {
		return 0, 0, err
	}
	online, err = s.engine.Where("status = ?", "online").Count(&model.Node{})
	if err != nil {
		return total, 0, err
	}
	return total, online, nil
}

// Encrypted Metric methods (Zero-Trust)

func (s *XORMStore) SaveEncryptedMetric(metric *model.EncryptedMetric) error {
	_, err := s.engine.Insert(metric)
	return err
}

func (s *XORMStore) GetEncryptedMetricsHistory(routingToken string, start, end time.Time, limit int) ([]*model.EncryptedMetric, error) {
	var metrics []*model.EncryptedMetric
	query := s.engine.
		Where("routing_token = ?", routingToken).
		Where("timestamp >= ?", start).
		Where("timestamp <= ?", end).
		OrderBy("timestamp DESC")
	if limit > 0 {
		query = query.Limit(limit)
	}
	err := query.Find(&metrics)
	return metrics, err
}

func (s *XORMStore) DeleteOldMetrics(before time.Time) error {
	_, err := s.engine.Where("timestamp < ?", before).Delete(&model.EncryptedMetric{})
	return err
}

// Encrypted Log methods (Zero-Trust)

func (s *XORMStore) SaveEncryptedLog(log *model.EncryptedLog) error {
	_, err := s.engine.Insert(log)
	return err
}

func (s *XORMStore) GetEncryptedLogsHistory(routingToken string, start, end time.Time, limit int) ([]*model.EncryptedLog, error) {
	var logs []*model.EncryptedLog
	query := s.engine.
		Where("routing_token = ?", routingToken).
		Where("timestamp >= ?", start).
		Where("timestamp <= ?", end).
		OrderBy("timestamp DESC")
	if limit > 0 {
		query = query.Limit(limit)
	}
	err := query.Find(&logs)
	return logs, err
}

func (s *XORMStore) CountLogs(routingToken string) (int64, error) {
	return s.engine.Where("routing_token = ?", routingToken).Count(&model.EncryptedLog{})
}

func (s *XORMStore) CountAllLogs() (int64, error) {
	return s.engine.Count(&model.EncryptedLog{})
}

func (s *XORMStore) GetEncryptedLogsByNode(routingToken, nodeID string, start, end time.Time, limit, offset int) ([]*model.EncryptedLog, error) {
	var logs []*model.EncryptedLog
	query := s.engine.Where("routing_token = ?", routingToken)
	if nodeID != "" {
		query = query.Where("node_id = ?", nodeID)
	}
	if !start.IsZero() {
		query = query.Where("timestamp >= ?", start)
	}
	if !end.IsZero() {
		query = query.Where("timestamp <= ?", end)
	}
	query = query.OrderBy("timestamp DESC")
	if limit > 0 {
		query = query.Limit(limit, offset)
	}
	err := query.Find(&logs)
	return logs, err
}

func (s *XORMStore) GetLogsStatsByRoutingToken() (map[string]int64, error) {
	result := make(map[string]int64)

	// Get all distinct routing tokens
	var logs []model.EncryptedLog
	err := s.engine.Distinct("routing_token").Find(&logs)
	if err != nil {
		return nil, err
	}

	// Count for each token
	for _, l := range logs {
		count, err := s.engine.Where("routing_token = ?", l.RoutingToken).Count(&model.EncryptedLog{})
		if err != nil {
			continue
		}
		result[l.RoutingToken] = count
	}
	return result, nil
}

func (s *XORMStore) GetLogStorageByRoutingToken() (map[string]int64, error) {
	result := make(map[string]int64)

	// Get all logs and sum by routing token
	var logs []model.EncryptedLog
	err := s.engine.Cols("routing_token", "encrypted_blob").Find(&logs)
	if err != nil {
		return nil, err
	}

	for _, l := range logs {
		result[l.RoutingToken] += int64(len(l.EncryptedBlob))
	}
	return result, nil
}

func (s *XORMStore) GetOldestAndNewestLog() (oldest, newest time.Time, err error) {
	var oldestLog, newestLog model.EncryptedLog

	has, err := s.engine.OrderBy("timestamp ASC").Limit(1).Get(&oldestLog)
	if err != nil {
		return
	}
	if has {
		oldest = oldestLog.Timestamp
	}

	has, err = s.engine.OrderBy("timestamp DESC").Limit(1).Get(&newestLog)
	if err != nil {
		return
	}
	if has {
		newest = newestLog.Timestamp
	}
	return
}

func (s *XORMStore) DeleteOldLogs(before time.Time) error {
	_, err := s.engine.Where("timestamp < ?", before).Delete(&model.EncryptedLog{})
	return err
}

func (s *XORMStore) DeleteOldestLogs(routingToken string, keepCount int) error {
	// Get logs to keep (most recent)
	var logsToKeep []model.EncryptedLog
	err := s.engine.
		Where("routing_token = ?", routingToken).
		OrderBy("timestamp DESC").
		Limit(keepCount).
		Find(&logsToKeep)
	if err != nil {
		return err
	}

	if len(logsToKeep) == 0 {
		return nil
	}

	// Delete all except the ones to keep
	keepIDs := make([]int64, len(logsToKeep))
	for i, l := range logsToKeep {
		keepIDs[i] = l.ID
	}

	_, err = s.engine.
		Where("routing_token = ?", routingToken).
		NotIn("id", keepIDs).
		Delete(&model.EncryptedLog{})
	return err
}

func (s *XORMStore) DeleteLogsByRoutingToken(routingToken string) (int64, error) {
	return s.engine.Where("routing_token = ?", routingToken).Delete(&model.EncryptedLog{})
}

func (s *XORMStore) DeleteLogsByNodeID(routingToken, nodeID string) (int64, error) {
	return s.engine.Where("routing_token = ?", routingToken).
		Where("node_id = ?", nodeID).
		Delete(&model.EncryptedLog{})
}

func (s *XORMStore) DeleteLogsBefore(routingToken string, before time.Time) (int64, error) {
	return s.engine.Where("routing_token = ?", routingToken).
		Where("timestamp < ?", before).
		Delete(&model.EncryptedLog{})
}

// User methods

func (s *XORMStore) SaveUser(user *model.User) error {
	exist, err := s.engine.Exist(&model.User{ID: user.ID})
	if err != nil {
		return err
	}
	if exist {
		_, err = s.engine.ID(user.ID).Update(user)
	} else {
		_, err = s.engine.Insert(user)
	}
	return err
}

func (s *XORMStore) GetUser(id string) (*model.User, error) {
	user := &model.User{ID: id}
	has, err := s.engine.Get(user)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("user not found")
	}
	return user, nil
}

func (s *XORMStore) GetUserByBlindIndex(index string) (*model.User, error) {
	user := &model.User{}
	has, err := s.engine.Where("blind_index = ?", index).Get(user)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("user not found")
	}
	return user, nil
}

func (s *XORMStore) UpdateUserTier(userID, tier string) error {
	_, err := s.engine.ID(userID).Cols("tier").Update(&model.User{Tier: tier})
	return err
}

func (s *XORMStore) ListUsers() ([]*model.User, error) {
	var users []*model.User
	err := s.engine.Find(&users)
	return users, err
}

func (s *XORMStore) DeleteUser(id string) error {
	_, err := s.engine.Delete(&model.User{ID: id})
	return err
}

// CountUsers returns user count (efficient counting)
func (s *XORMStore) CountUsers() (int64, error) {
	return s.engine.Count(&model.User{})
}

// FCM methods

func (s *XORMStore) SaveFCMToken(token *model.FCMToken) error {
	exist, err := s.engine.Exist(&model.FCMToken{Token: token.Token})
	if err != nil {
		return err
	}
	if exist {
		_, err = s.engine.ID(token.Token).Update(token)
	} else {
		_, err = s.engine.Insert(token)
	}
	return err
}

func (s *XORMStore) GetFCMTokensByTopic(fcmTopic string) ([]*model.FCMToken, error) {
	var tokens []*model.FCMToken
	err := s.engine.Where("f_c_m_topic = ?", fcmTopic).Find(&tokens)
	return tokens, err
}

func (s *XORMStore) DeleteFCMToken(token string) error {
	_, err := s.engine.Delete(&model.FCMToken{Token: token})
	return err
}

// Routing Token methods (Blind Routing)

func (s *XORMStore) SaveRoutingTokenInfo(info *model.RoutingTokenInfo) error {
	exist, err := s.engine.Exist(&model.RoutingTokenInfo{RoutingToken: info.RoutingToken})
	if err != nil {
		return err
	}
	if exist {
		_, err = s.engine.ID(info.RoutingToken).Update(info)
	} else {
		_, err = s.engine.Insert(info)
	}
	return err
}

func (s *XORMStore) GetRoutingTokenInfo(routingToken string) (*model.RoutingTokenInfo, error) {
	info := &model.RoutingTokenInfo{RoutingToken: routingToken}
	has, err := s.engine.Get(info)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("routing token not found")
	}
	return info, nil
}

func (s *XORMStore) UpdateRoutingTokenTier(routingToken, tier string) error {
	_, err := s.engine.ID(routingToken).Cols("tier").Update(&model.RoutingTokenInfo{Tier: tier})
	return err
}

func (s *XORMStore) UpdateTierByLicenseKey(licenseKey, tier string) error {
	_, err := s.engine.Where("license_key = ?", licenseKey).Cols("tier").Update(&model.RoutingTokenInfo{Tier: tier})
	return err
}

func (s *XORMStore) DeleteRoutingTokenInfo(routingToken string) error {
	_, err := s.engine.Delete(&model.RoutingTokenInfo{RoutingToken: routingToken})
	return err
}

// Pairing Token methods

func (s *XORMStore) SavePairingToken(token *model.PairingToken) error {
	exist, err := s.engine.Exist(&model.PairingToken{UserID: token.UserID})
	if err != nil {
		return err
	}
	if exist {
		_, err = s.engine.ID(token.UserID).Update(token)
	} else {
		_, err = s.engine.Insert(token)
	}
	return err
}

func (s *XORMStore) GetPairingToken(userID string) (*model.PairingToken, error) {
	token := &model.PairingToken{UserID: userID}
	has, err := s.engine.Get(token)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("pairing token not found")
	}
	return token, nil
}

// Certificate Revocation methods

func (s *XORMStore) SaveRevocation(rev *model.CertificateRevocation) error {
	_, err := s.engine.Insert(rev)
	return err
}

func (s *XORMStore) IsRevoked(serialNumber string) (bool, error) {
	return s.engine.Exist(&model.CertificateRevocation{SerialNumber: serialNumber})
}

func (s *XORMStore) IsRevokedByNodeID(nodeID string) (bool, error) {
	return s.engine.Where("common_name = ?", nodeID).Exist(&model.CertificateRevocation{})
}

func (s *XORMStore) IsRevokedByFingerprint(fingerprint string) (bool, error) {
	return s.engine.Where("fingerprint = ?", fingerprint).Exist(&model.CertificateRevocation{})
}

func (s *XORMStore) ListRevocationsByRoutingToken(routingToken string) ([]*model.CertificateRevocation, error) {
	var revs []*model.CertificateRevocation
	err := s.engine.Where("routing_token = ?", routingToken).Find(&revs)
	return revs, err
}

func (s *XORMStore) GetAllRevocations() ([]*model.CertificateRevocation, error) {
	var revs []*model.CertificateRevocation
	err := s.engine.Find(&revs)
	return revs, err
}

// Invite Code methods

func (s *XORMStore) GetInviteCode(code string) (*model.InviteCode, error) {
	ic := &model.InviteCode{Code: code}
	has, err := s.engine.Get(ic)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("invite code not found")
	}
	return ic, nil
}

func (s *XORMStore) SaveInviteCode(code *model.InviteCode) error {
	exist, err := s.engine.Exist(&model.InviteCode{Code: code.Code})
	if err != nil {
		return err
	}
	if exist {
		_, err = s.engine.ID(code.Code).Update(code)
	} else {
		_, err = s.engine.Insert(code)
	}
	return err
}

func (s *XORMStore) DeleteInviteCode(code string) error {
	_, err := s.engine.Delete(&model.InviteCode{Code: code})
	return err
}

func (s *XORMStore) IncrementInviteCodeUsage(code string) error {
	_, err := s.engine.Exec("UPDATE invite_code SET current_uses = current_uses + 1 WHERE code = ?", code)
	return err
}

func (s *XORMStore) ConsumeInviteCode(code string) error {
	session := s.engine.NewSession()
	defer session.Close()

	if err := session.Begin(); err != nil {
		return err
	}

	ic := &model.InviteCode{Code: code}
	has, err := session.Get(ic)
	if err != nil {
		return err
	}
	if !has {
		return errors.New("invite code not found")
	}

	// Check if active
	if !ic.Active {
		return errors.New("invite code is not active")
	}

	// Check expiry
	if !ic.ExpiresAt.IsZero() && time.Now().After(ic.ExpiresAt) {
		return errors.New("invite code has expired")
	}

	// Check max uses
	if ic.MaxUses > 0 && ic.CurrentUses >= ic.MaxUses {
		return errors.New("invite code has reached maximum uses")
	}

	// Increment
	if _, err := session.Exec("UPDATE invite_code SET current_uses = current_uses + 1 WHERE code = ?", code); err != nil {
		return err
	}

	return session.Commit()
}

func (s *XORMStore) CountInviteCodeUsage(code string) (int64, error) {
	ic := &model.InviteCode{Code: code}
	has, err := s.engine.Get(ic)
	if err != nil {
		return 0, err
	}
	if !has {
		return 0, errors.New("invite code not found")
	}
	return int64(ic.CurrentUses), nil
}

func (s *XORMStore) ListActiveInviteCodes() ([]*model.InviteCode, error) {
	var codes []*model.InviteCode
	err := s.engine.Where("active = ?", true).Find(&codes)
	return codes, err
}

// ProxyConfig methods

func (s *XORMStore) CreateProxyConfig(cfg *model.ProxyConfig) error {
	_, err := s.engine.Insert(cfg)
	return err
}

func (s *XORMStore) GetProxyConfig(proxyID string) (*model.ProxyConfig, error) {
	cfg := &model.ProxyConfig{ProxyID: proxyID}
	has, err := s.engine.Get(cfg)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("proxy config not found")
	}
	if cfg.Deleted {
		return nil, errors.New("proxy config has been deleted")
	}
	return cfg, nil
}

func (s *XORMStore) GetProxyConfigByRoutingToken(routingToken string) (*model.ProxyConfig, error) {
	cfg := &model.ProxyConfig{}
	has, err := s.engine.Where("routing_token = ? AND deleted = ?", routingToken, false).Get(cfg)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("proxy config not found")
	}
	return cfg, nil
}

func (s *XORMStore) ListProxyConfigsByRoutingToken(routingToken string) ([]*model.ProxyConfig, error) {
	var configs []*model.ProxyConfig
	err := s.engine.Where("routing_token = ? AND deleted = ?", routingToken, false).
		OrderBy("created_at DESC").Find(&configs)
	return configs, err
}

func (s *XORMStore) CountProxyConfigsByRoutingToken(routingToken string) (int64, error) {
	return s.engine.Where("routing_token = ? AND deleted = ?", routingToken, false).
		Count(&model.ProxyConfig{})
}

func (s *XORMStore) DeleteProxyConfig(proxyID string) error {
	// Soft delete
	_, err := s.engine.ID(proxyID).Cols("deleted", "updated_at").
		Update(&model.ProxyConfig{Deleted: true})
	return err
}

// ProxyRevision methods

func (s *XORMStore) CreateProxyRevision(rev *model.ProxyRevision) error {
	_, err := s.engine.Insert(rev)
	return err
}

func (s *XORMStore) GetProxyRevision(proxyID string, revisionNum int64) (*model.ProxyRevision, error) {
	rev := &model.ProxyRevision{}
	has, err := s.engine.Where("proxy_id = ? AND revision_num = ?", proxyID, revisionNum).Get(rev)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("revision not found")
	}
	return rev, nil
}

func (s *XORMStore) GetLatestProxyRevision(proxyID string) (*model.ProxyRevision, error) {
	rev := &model.ProxyRevision{}
	has, err := s.engine.Where("proxy_id = ?", proxyID).
		OrderBy("revision_num DESC").Limit(1).Get(rev)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("no revisions found")
	}
	return rev, nil
}

func (s *XORMStore) ListProxyRevisions(proxyID string) ([]*model.ProxyRevision, error) {
	var revisions []*model.ProxyRevision
	err := s.engine.Where("proxy_id = ?", proxyID).
		OrderBy("revision_num DESC").Find(&revisions)
	return revisions, err
}

func (s *XORMStore) CountProxyRevisions(proxyID string) (int64, error) {
	return s.engine.Where("proxy_id = ?", proxyID).Count(&model.ProxyRevision{})
}

func (s *XORMStore) DeleteProxyRevision(id int64) error {
	_, err := s.engine.ID(id).Delete(&model.ProxyRevision{})
	return err
}

func (s *XORMStore) DeleteOldestProxyRevisions(proxyID string, keepCount int) (int64, error) {
	if keepCount <= 0 {
		return 0, nil // Unlimited, don't delete
	}

	// Get all revisions ordered by revision_num DESC
	var revisions []*model.ProxyRevision
	err := s.engine.Where("proxy_id = ?", proxyID).
		OrderBy("revision_num DESC").Find(&revisions)
	if err != nil {
		return 0, err
	}

	if len(revisions) <= keepCount {
		return 0, nil // Nothing to delete
	}

	// Delete revisions beyond keepCount
	var deleted int64
	for i := keepCount; i < len(revisions); i++ {
		if _, err := s.engine.ID(revisions[i].ID).Delete(&model.ProxyRevision{}); err != nil {
			return deleted, err
		}
		deleted++
	}

	return deleted, nil
}

func (s *XORMStore) GetTotalProxyStorageByRoutingToken(routingToken string) (int64, error) {
	// Get all proxy configs for this routing token
	var proxies []*model.ProxyConfig
	err := s.engine.Where("routing_token = ? AND deleted = ?", routingToken, false).Find(&proxies)
	if err != nil {
		return 0, err
	}

	// Sum up storage for all revisions of all proxies
	var totalBytes int64
	for _, proxy := range proxies {
		var sum int64
		_, err := s.engine.Table("proxy_revision").
			Where("proxy_id = ?", proxy.ProxyID).
			Sum(&model.ProxyRevision{}, "size_bytes")
		if err != nil {
			// Alternative: count manually
			var revisions []*model.ProxyRevision
			if err := s.engine.Where("proxy_id = ?", proxy.ProxyID).Find(&revisions); err != nil {
				continue
			}
			for _, rev := range revisions {
				sum += int64(rev.SizeBytes)
			}
		}
		totalBytes += sum
	}

	return totalBytes, nil
}

// Approval Request methods

func (s *XORMStore) SaveApprovalRequest(req *model.ApprovalRequest) error {
	exist, err := s.engine.Exist(&model.ApprovalRequest{ID: req.ID})
	if err != nil {
		return err
	}
	if exist {
		_, err = s.engine.ID(req.ID).Update(req)
	} else {
		_, err = s.engine.Insert(req)
	}
	return err
}

func (s *XORMStore) GetApprovalRequest(id string) (*model.ApprovalRequest, error) {
	req := &model.ApprovalRequest{ID: id}
	has, err := s.engine.Get(req)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, errors.New("approval request not found")
	}
	return req, nil
}

func (s *XORMStore) ListPendingApprovalsByRoutingToken(routingToken string) ([]*model.ApprovalRequest, error) {
	var reqs []*model.ApprovalRequest
	err := s.engine.
		Where("routing_token = ?", routingToken).
		Where("status = ?", "pending").
		Where("expires_at > ?", time.Now()).
		Find(&reqs)
	return reqs, err
}

func (s *XORMStore) UpdateApprovalStatus(id, status string) error {
	_, err := s.engine.ID(id).Cols("status", "resolved_at").Update(&model.ApprovalRequest{
		Status:     status,
		ResolvedAt: time.Now(),
	})
	return err
}

// Audit Log methods (Zero-Trust: encrypted)

func (s *XORMStore) SaveAuditLog(log *model.AuditLog) error {
	_, err := s.engine.Insert(log)
	return err
}

func (s *XORMStore) GetAuditLogs(routingToken string, limit int) ([]*model.AuditLog, error) {
	var logs []*model.AuditLog
	query := s.engine.Where("routing_token = ?", routingToken).OrderBy("timestamp DESC")
	if limit > 0 {
		query = query.Limit(limit)
	}
	err := query.Find(&logs)
	return logs, err
}

func (s *XORMStore) CountAuditLogs(routingToken string) (int64, error) {
	return s.engine.Where("routing_token = ?", routingToken).Count(&model.AuditLog{})
}

func (s *XORMStore) DeleteExpiredAuditLogs() error {
	_, err := s.engine.Where("expires_at < ?", time.Now()).Delete(&model.AuditLog{})
	return err
}

func (s *XORMStore) DeleteOldestAuditLog(routingToken string) error {
	// Find the oldest log for this routing token
	log := &model.AuditLog{}
	has, err := s.engine.Where("routing_token = ?", routingToken).OrderBy("timestamp ASC").Limit(1).Get(log)
	if err != nil {
		return err
	}
	if !has {
		return nil
	}
	_, err = s.engine.ID(log.ID).Delete(&model.AuditLog{})
	return err
}

func (s *XORMStore) Close() error {
	return s.engine.Close()
}
