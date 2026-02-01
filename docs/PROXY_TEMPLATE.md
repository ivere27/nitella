# Proxy Template Management System

**Version**: 1.0

---

## 1. Overview

This document describes the design for proxy template management in Nitella, enabling:
- Version-controlled proxy configurations
- Revision history with tier-based limits
- Zero-trust storage on Hub
- CLI-based management workflow
- Diff between revisions

---

## 2. Protocol Versioning

All nitella YAML files must include a type/version header (first line) for forward compatibility:

```yaml
# nitella/proxy: v1; checksum=sha256:abc123...

meta:
  id: "proxy-uuid-1234"
  name: "Korea-only Web Proxy"
  ...
```

Or without checksum (optional):

```yaml
# nitella/proxy: v1

meta:
  id: "proxy-uuid-1234"
  ...
```

### Header Format (Single Line)

```
# nitella/<type>: v<version>[; checksum=sha256:<hash>]
```

- **Type**: `proxy`, `rules`, `tier`, `node` - Defines the YAML schema
- **Version**: `v1`, `v2`, etc. - Per-type version (breaking changes increment)
- **Checksum** (optional): SHA256 of content after header line

### Supported Types

| Type | Purpose | Current Version |
|------|---------|-----------------|
| `proxy` | Proxy configuration (entryPoints, routers, services) | v1 |
| `rules` | Standalone rules (shareable across proxies) | v1 |
| `tier` | Tier definitions (limits, quotas) | v1 |
| `node` | Node/nitellad configuration | v1 |

### Version Compatibility

Each type has independent versioning:

| Type | Version | CLI | nitellad | Notes |
|------|---------|-----|----------|-------|
| proxy | v1 | 1.0+ | 1.0+ | Initial release |
| rules | v1 | 1.0+ | 1.0+ | Initial release |
| tier | v1 | 1.0+ | - | Hub only |
| node | v1 | - | 1.0+ | nitellad only |

### Parser Implementation

```go
import "regexp"

var headerRegex = regexp.MustCompile(`^# nitella/(\w+): v(\d+)(?:; checksum=(.+))?$`)

type Header struct {
    Type     string // "proxy", "rules", "tier", "node"
    Version  int    // 1, 2, ... (per-type versioning)
    Checksum string // optional, empty if not provided
}

func ParseHeader(firstLine string) (*Header, error) {
    matches := headerRegex.FindStringSubmatch(firstLine)
    if matches == nil {
        return nil, errors.New("invalid header format")
    }

    version, _ := strconv.Atoi(matches[2])

    return &Header{
        Type:     matches[1],
        Version:  version,
        Checksum: matches[3], // empty if not present
    }, nil
}

func (h *Header) String() string {
    if h.Checksum != "" {
        return fmt.Sprintf("# nitella/%s: v%d; checksum=%s", h.Type, h.Version, h.Checksum)
    }
    return fmt.Sprintf("# nitella/%s: v%d", h.Type, h.Version)
}
```

---

## 3. Zero-Trust Architecture

### 3.1 The Problem

Hub must not be able to:
- Read proxy configuration content
- Correlate proxies to user identity
- See proxy names or descriptions

### 3.2 Design Decision: Fully Encrypted Metadata

**All user-visible data is encrypted. Hub only sees:**

| Field | Visibility | Purpose |
|-------|------------|---------|
| `proxy_id` | Plaintext | Stable UUID for routing |
| `routing_token` | Plaintext | Blind routing (HMAC) |
| `revision_num` | Plaintext | Sequence number |
| `encrypted_blob` | Encrypted | Everything else |
| `created_at` | Plaintext | TTL/cleanup |
| `size_bytes` | Plaintext | Quota enforcement |

**Inside `encrypted_blob` (E2E encrypted, Hub cannot read):**
```yaml
name: "Korea-only Web Proxy"
description: "Allow only Korean IPs"
commit_message: "Added rate limiting"
config:
  entryPoints: ...
  tcp: ...
```

### 3.3 Hub Storage Model

```go
// ProxyConfig - Hub can only see IDs and routing info
type ProxyConfig struct {
    ProxyID      string    `xorm:"pk"`           // UUID, visible
    RoutingToken string    `xorm:"unique index"` // Blind routing
    CreatedAt    time.Time `xorm:"created"`
    UpdatedAt    time.Time `xorm:"updated"`
    Deleted      bool      `xorm:"index"`        // Soft delete
    // NO name, description - those are encrypted
}

// ProxyRevision - Encrypted content per revision
type ProxyRevision struct {
    ID            int64     `xorm:"pk autoincr"`
    ProxyID       string    `xorm:"index"`        // FK
    RevisionNum   int64     `xorm:"unique(proxy_rev)"` // Sequence
    EncryptedBlob []byte    `xorm:"blob"`         // E2E encrypted
    SizeBytes     int32                           // For quota
    CreatedAt     time.Time `xorm:"created"`
    // NO commit_message - inside encrypted blob
}
```

### 3.4 Encrypted Blob Structure

```go
// ProxyRevisionPayload - Encrypted and stored in EncryptedBlob
type ProxyRevisionPayload struct {
    // Metadata (encrypted, Hub cannot see)
    Name          string `json:"name"`
    Description   string `json:"description"`
    CommitMessage string `json:"commit_message"`

    // Protocol version
    ProtocolVersion string `json:"protocol_version"` // "v1"

    // Actual config (YAML as string for diff)
    ConfigYAML    string `json:"config_yaml"`
    ConfigHash    string `json:"config_hash"` // SHA256 for integrity
}
```

### 3.5 Encryption Flow

```
CLI                           Hub
 │                             │
 │  1. Create ProxyRevisionPayload
 │     {name, desc, config}    │
 │                             │
 │  2. Encrypt with CLI key    │
 │     X25519 + AES-256-GCM    │
 │                             │
 │  3. Send encrypted blob ────▶  Store blob
 │     + proxyId               │  (cannot decrypt)
 │     + routingToken          │
 │                             │
 │  4. Retrieve blob ◀─────────│
 │                             │
 │  5. Decrypt locally         │
 │     Only CLI has key        │
```

---

## 4. Data Structures

### 4.1 YAML Format (proxy v1)

```yaml
# nitella/proxy: v1; checksum=sha256:e3b0c44298fc1c149afbf4c8996fb924...

meta:
  id: "550e8400-e29b-41d4-a716-446655440000"
  name: "Production Web Proxy"
  description: "Main proxy for Korean traffic"
  created_at: "2026-02-01T10:00:00Z"
  updated_at: "2026-02-01T12:30:00Z"

entryPoints:
  web:
    address: ":8443"
    defaultAction: block
    defaultMock: http-403
    tls:
      certFile: /etc/nitella/cert.pem
      keyFile: /etc/nitella/key.pem
      clientAuth: optional

tcp:
  routers:
    allow-korea:
      entryPoints: ["web"]
      rule: "GeoCountry(`KR`)"
      service: backend
      priority: 100

    block-datacenter:
      entryPoints: ["web"]
      rule: "GeoISP(`AWS`) || GeoISP(`Google Cloud`)"
      service: honeypot
      priority: 90

  services:
    backend:
      address: "192.168.1.100:80"
      healthCheck:
        interval: "10s"
        timeout: "2s"
        type: http
        path: /health
        expectedStatus: 200

    honeypot:
      address: "127.0.0.1:9999"

  middlewares:
    tarpit:
      mock:
        preset: ssh-tarpit
        delayMs: 5000
```

### 4.2 Revision Info (Decrypted by CLI)

```go
type RevisionInfo struct {
    RevisionNum   int64     `json:"revision_num"`
    Name          string    `json:"name"`
    CommitMessage string    `json:"commit_message"`
    CreatedAt     time.Time `json:"created_at"`
    SizeBytes     int32     `json:"size_bytes"`
    ConfigHash    string    `json:"config_hash"`
}
```

---

## 5. Tier Limits

### 5.1 Updated tiers.yaml

```yaml
tiers:
  - id: "free"
    proxy_management:
      enabled: true
      max_proxies: 3
      max_revisions_per_proxy: 1    # Only latest revision kept
      max_storage_kb: 100
      ttl_days: 7

  - id: "pro"
    proxy_management:
      enabled: true
      max_proxies: 20
      max_revisions_per_proxy: 5    # Keep last 5 revisions
      max_storage_kb: 1024
      ttl_days: 30

  - id: "business"
    proxy_management:
      enabled: true
      max_proxies: 0                # Unlimited
      max_revisions_per_proxy: 0    # Unlimited while proxy exists
      max_storage_kb: 0             # Unlimited (fair use)
      ttl_days: 365
```

### 5.2 Revision Pruning Logic

```go
func (s *HubServer) pruneRevisions(proxyID string, keepCount int) error {
    if keepCount <= 0 {
        return nil // Unlimited
    }

    // Get all revisions ordered by revision_num DESC
    revisions, _ := s.store.ListRevisions(proxyID)

    if len(revisions) <= keepCount {
        return nil
    }

    // Delete oldest revisions beyond limit
    for i := keepCount; i < len(revisions); i++ {
        s.store.DeleteRevision(revisions[i].ID)
    }

    return nil
}
```

---

## 6. CLI Commands

### 6.1 Local Management

```bash
# Import YAML file into CLI management
nitella proxy import <file.yaml> [--name "My Proxy"]
# Creates: ~/.nitella/proxies/<uuid>.yaml

# List local proxies
nitella proxy list [--local | --remote | --all]
# Output:
#   ID          NAME                 STATUS     REVISIONS  LAST MODIFIED
#   550e8400... Production Web       synced     3          2026-02-01 12:30
#   662f9500... Dev Proxy            local      -          2026-02-01 10:00

# Edit proxy (opens $EDITOR)
nitella proxy edit <proxy-id>

# Show proxy details
nitella proxy show <proxy-id> [--revision N]

# Export to file
nitella proxy export <proxy-id> [--revision N] [--output file.yaml]

# Delete local proxy
nitella proxy delete <proxy-id> [--remote] [--force]
```

### 6.2 Hub Sync

```bash
# Push to Hub (creates new revision)
nitella proxy push <proxy-id> [--message "Added rate limiting"]
# Output:
#   Pushed revision 4 of proxy 550e8400...
#   Revisions: 4/5 (pro tier)
#   Storage: 12KB/1024KB

# Pull from Hub
nitella proxy pull <proxy-id> [--revision N]
# Downloads and saves to ~/.nitella/proxies/

# List revisions
nitella proxy history <proxy-id>
# Output:
#   REV  MESSAGE              DATE                 SIZE
#   4    Added rate limiting  2026-02-01 12:30:00  3.2KB
#   3    Fixed geo rule       2026-02-01 11:00:00  3.1KB
#   2    Initial config       2026-02-01 10:00:00  2.8KB

# Diff between revisions
nitella proxy diff <proxy-id> [--rev1 N] [--rev2 M]
# Default: diff between latest and previous
# Output: unified diff format

# Flush old revisions (keep only latest)
nitella proxy flush <proxy-id> [--keep N]
```

### 6.3 Apply to Node

```bash
# Apply proxy to node
nitella proxy apply <proxy-id> <node-id> [--revision N]
# Output:
#   Applied proxy 550e8400... (rev 4) to node abc123...
#   Status: active

# Check applied proxies on node
nitella proxy status <node-id>
# Output:
#   PROXY ID     REV  APPLIED AT           STATUS
#   550e8400...  4    2026-02-01 12:35:00  active
#   662f9500...  2    2026-02-01 10:00:00  active

# Remove proxy from node
nitella proxy unapply <proxy-id> <node-id>
```

---

## 7. Diff Implementation

### 7.1 Diff Command Flow

```
nitella proxy diff <proxy-id> --rev1 2 --rev2 4

1. Fetch revision 2 encrypted blob from Hub
2. Fetch revision 4 encrypted blob from Hub
3. Decrypt both locally (CLI has key)
4. Extract ConfigYAML from each
5. Run unified diff algorithm
6. Display colorized output
```

### 7.2 Diff Output Format

```diff
--- revision 2 (2026-02-01 10:00:00)
+++ revision 4 (2026-02-01 12:30:00)
@@ -15,6 +15,12 @@ tcp:
       rule: "GeoCountry(`KR`)"
       service: backend
       priority: 100
+
+    block-datacenter:
+      entryPoints: ["web"]
+      rule: "GeoISP(`AWS`) || GeoISP(`Google Cloud`)"
+      service: honeypot
+      priority: 90

   services:
     backend:
```

### 7.3 Diff Implementation (Go)

```go
// pkg/diff/diff.go

import "github.com/sergi/go-diff/diffmatchpatch"

func UnifiedDiff(oldText, newText, oldLabel, newLabel string) string {
    dmp := diffmatchpatch.New()

    // Line-mode diff for better readability
    a, b, c := dmp.DiffLinesToChars(oldText, newText)
    diffs := dmp.DiffMain(a, b, false)
    diffs = dmp.DiffCharsToLines(diffs, c)

    // Convert to unified format
    return formatUnifiedDiff(diffs, oldLabel, newLabel)
}
```

---

## 8. Hub RPC Protocol

### 8.1 Protobuf Definitions

```protobuf
// api/hub/hub_mobile.proto

service MobileService {
  // ... existing ...

  // Proxy Management (Zero-Trust: encrypted content)
  rpc CreateProxy(CreateProxyRequest) returns (CreateProxyResponse);
  rpc ListProxies(ListProxiesRequest) returns (ListProxiesResponse);
  rpc DeleteProxy(DeleteProxyRequest) returns (Empty);

  // Revision Management
  rpc PushRevision(PushRevisionRequest) returns (PushRevisionResponse);
  rpc GetRevision(GetRevisionRequest) returns (GetRevisionResponse);
  rpc ListRevisions(ListRevisionsRequest) returns (ListRevisionsResponse);
  rpc FlushRevisions(FlushRevisionsRequest) returns (FlushRevisionsResponse);
}

// Create new proxy (just ID, no content yet)
message CreateProxyRequest {
  string proxy_id = 1;           // Client-generated UUID
  string routing_token = 2;      // HMAC for blind routing
}

message CreateProxyResponse {
  bool success = 1;
  string error = 2;
}

// List proxies (returns IDs only - names are encrypted)
message ListProxiesRequest {
  string routing_token = 1;      // Filter by routing token
}

message ListProxiesResponse {
  repeated ProxyInfo proxies = 1;
}

message ProxyInfo {
  string proxy_id = 1;
  int64 revision_count = 2;
  int64 latest_revision = 3;
  google.protobuf.Timestamp created_at = 4;
  google.protobuf.Timestamp updated_at = 5;
  int32 total_size_bytes = 6;
}

// Push new revision
message PushRevisionRequest {
  string proxy_id = 1;
  string routing_token = 2;
  bytes encrypted_blob = 3;      // E2E encrypted payload
  int32 size_bytes = 4;          // For quota check
}

message PushRevisionResponse {
  bool success = 1;
  int64 revision_num = 2;        // Assigned revision number
  int32 revisions_kept = 3;      // After pruning
  int32 revisions_limit = 4;     // Tier limit
  int32 storage_used_kb = 5;
  int32 storage_limit_kb = 6;
  string error = 7;
}

// Get specific revision
message GetRevisionRequest {
  string proxy_id = 1;
  string routing_token = 2;
  int64 revision_num = 3;        // 0 = latest
}

message GetRevisionResponse {
  bytes encrypted_blob = 1;
  int64 revision_num = 2;
  google.protobuf.Timestamp created_at = 3;
}

// List revisions (metadata only - no content)
message ListRevisionsRequest {
  string proxy_id = 1;
  string routing_token = 2;
}

message ListRevisionsResponse {
  repeated RevisionMeta revisions = 1;
}

message RevisionMeta {
  int64 revision_num = 1;
  int32 size_bytes = 2;
  google.protobuf.Timestamp created_at = 3;
  // NOTE: commit_message is inside encrypted_blob
}

// Flush old revisions
message FlushRevisionsRequest {
  string proxy_id = 1;
  string routing_token = 2;
  int32 keep_count = 3;          // Keep N most recent (0 = keep only latest)
}

message FlushRevisionsResponse {
  bool success = 1;
  int32 deleted_count = 2;
  int32 remaining_count = 3;
}
```

---

## 9. Auto-Update (Push to nitellad)

When a proxy config is updated (new revision pushed to Hub), nodes that have applied that proxyId should automatically receive the update.

### 9.1 Flow

```
CLI pushes revision     Hub                     nitellad
        │                │                          │
        │ PushRevision   │                          │
        │───────────────▶│                          │
        │                │                          │
        │                │ Find nodes with proxyId  │
        │                │ applied (RoutingToken)   │
        │                │                          │
        │                │ Notify via:              │
        │                │ - Active stream (if any) │
        │                │ - FCM push (fallback)    │
        │                │──────────────────────────▶
        │                │                          │
        │                │                          │ Receive notification
        │                │                          │ Fetch latest revision
        │                │◀─────────────────────────│ GetRevision(proxyId, 0)
        │                │                          │
        │                │──────────────────────────▶│
        │                │                          │ Decrypt & apply
        │                │                          │ Update AppliedProxy
```

### 9.2 Notification Payload

```go
type ProxyUpdateNotification struct {
    ProxyID     string `json:"proxy_id"`
    RevisionNum int64  `json:"revision_num"`
    Action      string `json:"action"` // "updated" or "deleted"
}
```

### 9.3 nitellad Subscription

nitellad maintains a subscription to proxy updates:
- On apply: Register interest in proxyId updates
- On unapply: Unregister from updates
- On notification: Fetch latest revision and apply

---

## 10. nitellad Integration

### 10.1 Applied Proxy Tracking

```go
// pkg/node/applied.go

type AppliedProxy struct {
    ProxyID     string    `xorm:"pk"`
    RevisionNum int64
    ConfigHash  string    // For detecting drift
    AppliedAt   time.Time
    Status      string    // "active", "stopped", "error"
    ErrorMsg    string    `xorm:"text"`
}

type AppliedProxyManager struct {
    db       *xorm.Engine
    proxies  map[string]*AppliedProxy
    mu       sync.RWMutex
}
```

### 10.2 Command Types

```protobuf
// api/common/common.proto

enum CommandType {
  // ... existing ...

  COMMAND_TYPE_APPLY_PROXY = 20;    // Apply proxy config
  COMMAND_TYPE_UNAPPLY_PROXY = 21;  // Remove proxy config
  COMMAND_TYPE_GET_APPLIED = 22;    // List applied proxies
}
```

### 10.3 Apply Flow

```
CLI                     Hub                     nitellad
 │                       │                         │
 │ apply <proxy> <node>  │                         │
 │──────────────────────▶│                         │
 │                       │                         │
 │ GetRevision(proxy,N)  │                         │
 │◀──────────────────────│                         │
 │                       │                         │
 │ Decrypt locally       │                         │
 │ Re-encrypt for node   │                         │
 │                       │                         │
 │ SendCommand ──────────▶ Relay ─────────────────▶│
 │ (APPLY_PROXY)         │                         │
 │                       │                         │
 │                       │                         │ Decrypt
 │                       │                         │ Parse YAML
 │                       │                         │ Create listeners
 │                       │                         │ Save AppliedProxy
 │                       │                         │
 │◀──────────────────────┼─────────────────────────│
 │ Result: OK            │                         │
```

---

## 11. Security Considerations

### 11.1 What Hub CAN See

- `proxy_id` (UUID) - Required for routing
- `routing_token` - Blind identifier
- `revision_num` - Sequence number
- `size_bytes` - For quota enforcement
- `created_at`, `updated_at` - Timestamps

### 11.2 What Hub CANNOT See

- Proxy name
- Proxy description
- Commit messages
- Configuration content (entryPoints, routers, services)
- Rule expressions
- Backend addresses
- Any user-identifiable information

### 11.3 Encryption Details

- **Algorithm**: X25519 ECDH + AES-256-GCM (existing envelope.go)
- **Key**: CLI's Ed25519 private key (derived from mnemonic)
- **AAD**: Includes proxy_id + revision_num for binding
- **Signature**: Ed25519 signature for authenticity

### 11.4 Threat Model

| Threat | Mitigation |
|--------|------------|
| Hub reads config | E2E encryption - Hub has no key |
| Hub correlates users | Blind routing tokens (HMAC) |
| Replay attack | Signature + revision sequence |
| Tampering | Checksum in encrypted payload |
| Storage exhaustion | Tier-based quotas |

---

## 12. Example Session

```bash
# Import existing config
$ nitella proxy import /etc/nitella/web.yaml --name "Production Web"
Created proxy 550e8400-e29b-41d4-a716-446655440000
Saved to ~/.nitella/proxies/550e8400.yaml

# Edit configuration
$ nitella proxy edit 550e8400
# ... editor opens ...

# Push to Hub
$ nitella proxy push 550e8400 -m "Added GeoIP blocking"
Encrypting configuration...
Pushed revision 1 to Hub
Storage: 3KB / 100KB (free tier)
Revisions: 1/1

# Make another change and push
$ nitella proxy edit 550e8400
$ nitella proxy push 550e8400 -m "Fixed backend address"
Pushed revision 2 to Hub
Revisions: 1/1 (pruned revision 1 - free tier limit)

# View history
$ nitella proxy history 550e8400
REV  MESSAGE               DATE                 SIZE
2    Fixed backend address 2026-02-01 12:30:00  3.2KB

# Apply to node
$ nitella proxy apply 550e8400 node-abc123
Fetching revision 2...
Encrypting for node...
Sending to node via Hub...
Applied successfully!

# Check status
$ nitella proxy status node-abc123
PROXY ID     REV  APPLIED AT           STATUS
550e8400...  2    2026-02-01 12:35:00  active
```
