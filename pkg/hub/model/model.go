package model

import (
	"time"
)

// Node represents a managed proxy node
// Zero-Trust: No OwnerID - Hub cannot correlate nodes to users
type Node struct {
	ID                string `xorm:"pk"`
	RoutingToken      string `xorm:"unique"` // Blind routing identifier (replaces OwnerID)
	EncryptedMetadata []byte `xorm:"blob"`   // E2E Encrypted Name and other metadata
	Status            string
	LastSeen          time.Time
	CertPEM           string    `xorm:"text"` // Client certificate for mTLS
	PublicKeyPEM      string    `xorm:"text"`
	CreatedAt         time.Time `xorm:"created"`
	UpdatedAt         time.Time `xorm:"updated"`
	// Note: PublicIP, ListenPorts, Version, GeoIPEnabled moved to EncryptedMetadata
}

// User represents an authenticated user
type User struct {
	ID               string `xorm:"pk"`
	BlindIndex       string `xorm:"unique"` // SHA256(Email + Salt)
	EncryptedProfile []byte `xorm:"blob"`   // Encrypted Email, Avatar, etc.
	Role             string
	LastLogin        time.Time

	// Internal fields not in Proto
	PublicKeyPEM       string `xorm:"text"`
	BiometricPublicKey []byte `xorm:"blob"` // Raw Ed25519 public key
	Tier               string // free, pro, business
	MaxNodes           int
	LicenseKey         string    // Invite Code / License Key
	InviteCode         string    // Code used to register
	CreatedAt          time.Time `xorm:"created"`
}

// RoutingTokenInfo stores routing metadata for blind routing
// Zero-Trust: Hub routes by token, cannot correlate to user identity
type RoutingTokenInfo struct {
	RoutingToken string    `xorm:"pk"`           // HMAC(node_id, user_secret)
	LicenseKey   string    `xorm:"index"`        // For tier lookups and bulk updates
	Tier         string    `xorm:"index"`        // free, pro, business
	FCMTopic     string    `xorm:"index"`        // FCM topic for mobile push
	AuditPubKey  []byte    `xorm:"blob"`         // Ed25519 public key for encrypting audit logs
	CreatedAt    time.Time `xorm:"created"`
	UpdatedAt    time.Time `xorm:"updated"`
}

// FCMToken stores Firebase Cloud Messaging device tokens
// Zero-Trust: Linked to FCMTopic (blind), not UserID
type FCMToken struct {
	Token      string    `xorm:"pk"`
	FCMTopic   string    `xorm:"index"` // Blind topic (replaces UserID)
	DeviceType string    // android, ios, web
	UpdatedAt  time.Time `xorm:"updated"`
}

// RegistrationRequest represents a pending node registration request
type RegistrationRequest struct {
	Code              string `xorm:"pk"`
	CSR               string `xorm:"text"`
	EncryptedMetadata []byte `xorm:"blob"`
	NodeID            string // Extracted from CSR
	RoutingToken      string // Blind routing token (provided by CLI during pairing)
	Status            string // PENDING, APPROVED, REJECTED
	CertPEM           string `xorm:"text"`
	CaPEM             string `xorm:"text"`
	LicenseKey        string    // License key for tier lookup
	WatchSecret       string    // Secret required for WatchRegistration (only registrant knows)
	ExpiresAt         time.Time `xorm:"index"`
	CreatedAt         time.Time `xorm:"created"`
	UpdatedAt         time.Time `xorm:"updated"`
	Version           int       `xorm:"version"` // Optimistic locking for TOCTOU prevention
}

// InviteCode represents an invitation code for user registration
type InviteCode struct {
	Code          string    `xorm:"pk"`
	CreatedBy     string    `xorm:"index"` // Admin who created it
	MaxUses       int       // 0 = unlimited
	CurrentUses   int
	TierID        string    // Tier assigned to users who use this code
	ExpiresAt     time.Time `xorm:"index"`
	CreatedAt     time.Time `xorm:"created"`
	Note          string    // Optional admin note
	Active        bool      `xorm:"index default 1"`
}

// EncryptedMetric stores encrypted metrics for zero-trust architecture
// Hub cannot decrypt - only stores and retrieves encrypted blobs
type EncryptedMetric struct {
	ID            int64     `xorm:"pk autoincr"`
	NodeID        string    `xorm:"'node_id' index"`
	RoutingToken  string    `xorm:"'routing_token' index"` // For retrieval by owner
	Timestamp     time.Time `xorm:"'timestamp' index"`
	EncryptedBlob []byte    `xorm:"'encrypted_blob' blob"` // E2E encrypted metrics
	Nonce         []byte    `xorm:"'nonce' blob"`          // Encryption nonce
	SenderKeyID   string    `xorm:"'sender_key_id'"`       // Key ID for decryption
}

// EncryptedLog stores encrypted logs for zero-trust architecture
// Hub cannot decrypt - only stores and retrieves encrypted blobs
type EncryptedLog struct {
	ID            int64     `xorm:"'id' pk autoincr"`
	NodeID        string    `xorm:"'node_id' index"`
	RoutingToken  string    `xorm:"'routing_token' index"` // For retrieval by owner
	Timestamp     time.Time `xorm:"'timestamp' index"`
	EncryptedBlob []byte    `xorm:"'encrypted_blob' blob"` // E2E encrypted log entry
	Nonce         []byte    `xorm:"'nonce' blob"`          // Encryption nonce
	SenderKeyID   string    `xorm:"'sender_key_id'"`       // Key ID for decryption
}

// PairingToken represents a short-lived token for securing pairing
type PairingToken struct {
	UserID    string `xorm:"pk"`
	Token     string
	ExpiresAt time.Time
	CreatedAt time.Time `xorm:"created"`
}

// CertificateRevocation represents a revoked certificate
// Zero-Trust: Linked to RoutingToken, not OwnerID
type CertificateRevocation struct {
	SerialNumber string    `xorm:"pk"`    // Certificate serial number (hex string)
	RoutingToken string    `xorm:"index"` // Blind routing (replaces OwnerID)
	CommonName   string    // CN from cert
	Reason       string    // Revocation reason (key_compromise, cessation, superseded, etc.)
	RevokedAt    time.Time `xorm:"created"`
	Fingerprint  string    // SHA256 fingerprint for quick lookup
}

// ProxyConfig stores proxy configuration metadata
// Zero-Trust: No name/description - those are inside encrypted revisions
type ProxyConfig struct {
	ProxyID      string    `xorm:"pk 'proxy_id'"`           // UUID, stable across revisions
	RoutingToken string    `xorm:"unique index"`            // Blind routing (HMAC)
	CreatedAt    time.Time `xorm:"created"`
	UpdatedAt    time.Time `xorm:"updated"`
	Deleted      bool      `xorm:"index default 0"`         // Soft delete
}

// ProxyRevision stores each revision of a proxy config
// Zero-Trust: All user data (name, description, config) is encrypted
type ProxyRevision struct {
	ID            int64     `xorm:"pk autoincr"`
	ProxyID       string    `xorm:"index 'proxy_id'"`                    // FK to ProxyConfig
	RevisionNum   int64     `xorm:"unique(proxy_rev) 'revision_num'"`    // Sequence: 1, 2, 3...
	EncryptedBlob []byte    `xorm:"blob 'encrypted_blob'"`               // E2E encrypted payload
	SizeBytes     int32     `xorm:"'size_bytes'"`                        // For quota enforcement
	CreatedAt     time.Time `xorm:"created"`
}

// ProxyRevisionPayload is encrypted inside ProxyRevision.EncryptedBlob
// Only the user can decrypt this - Hub never sees config content
type ProxyRevisionPayload struct {
	// Metadata (encrypted, Hub cannot see)
	Name          string `json:"name"`
	Description   string `json:"description"`
	CommitMessage string `json:"commit_message"`

	// Protocol version
	ProtocolVersion string `json:"protocol_version"` // "v1"

	// Actual config (YAML as string for diff)
	ConfigYAML string `json:"config_yaml"`
	ConfigHash string `json:"config_hash"` // SHA256 for integrity
}

// ApprovalRequest represents a pending connection approval request
// Zero-Trust: All content is encrypted, Hub only sees routing_token
type ApprovalRequest struct {
	ID               string    `xorm:"pk"`
	RoutingToken     string    `xorm:"index"` // Blind routing (replaces NodeID + OwnerID)
	EncryptedPayload []byte    `xorm:"blob"`  // E2E encrypted: contains SourceIP, DestAddr, details
	Status           string    // pending, approved, denied
	ExpiresAt        time.Time `xorm:"index"`
	CreatedAt        time.Time `xorm:"created"`
	ResolvedAt       time.Time
}

// ApprovalRequestDetails is encrypted inside ApprovalRequest.EncryptedPayload
// Only the user can decrypt this - Hub never sees traffic metadata
type ApprovalRequestDetails struct {
	SourceIP    string            `json:"source_ip"`
	DestAddr    string            `json:"dest_addr"`
	Protocol    string            `json:"protocol,omitempty"`
	RuleName    string            `json:"rule_name,omitempty"`
	Reason      string            `json:"reason,omitempty"`
	Metadata    map[string]string `json:"metadata,omitempty"`
}

// AuditLog stores encrypted audit events
// Zero-Trust: Hub stores encrypted blob, cannot read content
type AuditLog struct {
	ID               int64     `xorm:"pk autoincr"`
	RoutingToken     string    `xorm:"index"` // For retrieval (blind)
	Timestamp        time.Time `xorm:"index"` // For expiry cleanup
	EncryptedPayload []byte    `xorm:"blob"`  // Hub cannot read (event_type + content encrypted)
	ExpiresAt        time.Time `xorm:"index"` // Based on tier
}

// AuditLogPayload is encrypted inside AuditLog.EncryptedPayload
// Only the user can decrypt this
type AuditLogPayload struct {
	EventID   string            `json:"event_id"`
	EventType string            `json:"event_type"` // approval_request, approval_granted, alert, etc.
	Timestamp time.Time         `json:"timestamp"`
	NodeID    string            `json:"node_id,omitempty"`
	Details   map[string]string `json:"details,omitempty"`
}
