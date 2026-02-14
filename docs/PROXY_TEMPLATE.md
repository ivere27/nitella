# Proxy Template Management System

---

## 1. Overview

Nitella provides two complementary systems for managing proxy configurations:

1. **Templates** — Snapshot-based capture of a node's proxy configuration (proxies + rules), stored locally, applied to other nodes, with YAML import/export.
2. **Proxy Config Versioning** — Version-controlled proxy configurations stored on the Hub with E2E encryption, revision history, push/pull/diff workflow, and deployment to nodes.

---

## 2. Templates

Templates capture a snapshot of a node's current proxy and rule configuration. They are stored locally and can be applied to other nodes for consistent security policies.

### 2.1 Data Model

```protobuf
message Template {
  string template_id = 1;       // Random 8-byte hex ID
  string name = 2;
  string description = 3;
  Timestamp created_at = 4;
  Timestamp updated_at = 5;
  string author = 6;            // Identity fingerprint
  bool is_public = 7;
  int32 downloads = 8;
  repeated string tags = 9;
  repeated ProxyTemplate proxies = 10;
}

message ProxyTemplate {
  string name = 1;
  string listen_addr = 2;
  ActionType default_action = 3;
  FallbackAction fallback_action = 4;
  repeated Rule rules = 5;
  repeated string tags = 6;
}
```

### 2.2 Operations

| RPC | Description |
|-----|-------------|
| `CreateTemplate` | Captures current proxy + rule config from a node |
| `ApplyTemplate` | Deploys proxies and rules to a target node |
| `ListTemplates` | Lists templates with optional tag filtering |
| `GetTemplate` | Retrieves a specific template |
| `DeleteTemplate` | Removes a template |
| `ExportTemplateYaml` | Exports template as YAML text |
| `ImportTemplateYaml` | Parses YAML into a template |

### 2.3 Create Flow

1. User selects a source node
2. Backend fetches proxy list from node via `sendCommand()`
3. For each proxy, backend fetches rules via `sendCommand()`
4. A `Template` is created with `ProxyTemplate` entries
5. Template is stored locally

### 2.4 Apply Flow

1. User selects a template and a target node
2. For each `ProxyTemplate` in the template:
   - Sends `COMMAND_TYPE_APPLY_PROXY` to create the proxy on the node
   - For each rule in the proxy template, sends `COMMAND_TYPE_ADD_RULE`
3. Returns counts of proxies and rules created

### 2.5 YAML Format

Templates use a simple YAML format without protocol headers:

```yaml
name: "Web Filter Template"
description: "Block common threats"
tags:
  - security
  - web
proxies:
  - name: "http-proxy"
    listen_addr: "0.0.0.0:8080"
    default_action: ALLOW
    fallback_action: CLOSE
    rules:
      - name: "Block datacenter IPs"
        priority: 100
        action: BLOCK
        expression: "geo_isp == 'AWS' || geo_isp == 'Google Cloud'"
      - name: "Allow Korea only"
        priority: 90
        action: ALLOW
        expression: "geo_country == 'KR'"
```

**Parsing rules:**
- `name` is required; `description`, `tags`, `proxies` are optional
- Action types: `ALLOW`, `BLOCK`, `MOCK`, `REQUIRE_APPROVAL`, `2FA` (case-insensitive)
- Fallback actions: `CLOSE`, `MOCK`
- Rules use `expression` field for condition matching

### 2.6 Storage

Templates are stored in-memory in the `MobileLogicService.templates` map with file-based persistence under `~/.nitella/templates/`.

---

## 3. Proxy Config Versioning

The proxy config versioning system provides version-controlled proxy configurations stored on the Hub with full E2E encryption.

### 3.1 Zero-Trust Architecture

All user-visible data is encrypted. Hub only sees:

| Field | Visibility | Purpose |
|-------|------------|---------|
| `proxy_id` | Plaintext | Stable UUID for routing |
| `routing_token` | Plaintext | Blind routing (HMAC) |
| `revision_num` | Plaintext | Sequence number |
| `encrypted_blob` | Encrypted | Everything else |
| `created_at` | Plaintext | TTL/cleanup |
| `size_bytes` | Plaintext | Quota enforcement |

Inside the encrypted blob (Hub cannot read):
```json
{
  "name": "Korea-only Web Proxy",
  "description": "Allow only Korean IPs",
  "commit_message": "Added rate limiting",
  "config_yaml": "...",
  "config_hash": "sha256:..."
}
```

### 3.2 Protocol Versioning

All nitella YAML files include a type/version header:

```yaml
# nitella/proxy: v1; checksum=sha256:abc123...

meta:
  id: "550e8400-e29b-41d4-a716-446655440000"
  name: "Production Web Proxy"
  ...
```

**Header format:**
```
# nitella/<type>: v<version>[; checksum=sha256:<hash>]
```

| Type | Purpose | Current Version |
|------|---------|-----------------|
| `proxy` | Proxy configuration | v1 |
| `rules` | Standalone rules | v1 |
| `tier` | Tier definitions | v1 |
| `node` | Node configuration | v1 |

Header parsing regex:
```
^#\s*nitella/(\w+):\s*v(\d+)(?:;\s*checksum=(.+))?$
```

### 3.3 Local Storage

Proxy configs are stored locally at:
- **Index:** `~/.nitella/proxies/index.json` (maps proxyID to metadata)
- **Configs:** `~/.nitella/proxies/{proxyID}.yaml` (full YAML content with header)

Proxy IDs support prefix matching (e.g., `550e8400` matches the full UUID).

**Local metadata:**
```protobuf
message LocalProxyConfig {
  string proxy_id = 1;
  string name = 2;
  string description = 3;
  Timestamp created_at = 4;
  Timestamp updated_at = 5;
  Timestamp synced_at = 6;       // When last pushed to Hub
  int64 revision_num = 7;        // Hub revision number
  string config_hash = 8;        // SHA256 of content
}
```

### 3.4 Hub Sync Operations

| RPC | Description |
|-----|-------------|
| `PushProxyRevision` | Encrypt and upload config as new revision |
| `PullProxyRevision` | Fetch and decrypt revision from Hub |
| `ListProxyRevisions` | List revision metadata (number, size, timestamp) |
| `DiffProxyRevisions` | Unified diff between revisions (local vs remote, or A vs B) |
| `FlushProxyRevisions` | Delete old revisions, keep N recent |
| `ListProxyConfigs` | List all proxy configs on Hub |
| `CreateProxyConfig` | Create Hub entry for a proxy |
| `DeleteProxyConfig` | Remove proxy from Hub |

### 3.5 Push Response

```protobuf
message PushProxyRevisionResponse {
  int64 revision_num = 1;       // Assigned revision number
  int32 revisions_kept = 2;     // After pruning
  int32 revisions_limit = 3;    // Tier limit
  int32 storage_used_kb = 4;
  int32 storage_limit_kb = 5;
}
```

### 3.6 Diff Support

```protobuf
message DiffProxyRevisionsResponse {
  string unified_diff = 1;      // Unified diff text
  bool has_differences = 2;
}
```

Diff supports:
- Local config vs latest Hub revision (`local_vs_latest=true`)
- Hub revision A vs Hub revision B

### 3.7 Encryption Flow

```
CLI/Mobile                    Hub
 |                             |
 |  1. Create payload          |
 |     {name, desc, config}    |
 |                             |
 |  2. Encrypt with user key   |
 |     X25519 + AES-256-GCM    |
 |                             |
 |  3. Send encrypted blob ----+-> Store blob
 |     + proxyId               |   (cannot decrypt)
 |     + routingToken          |
 |                             |
 |  4. Retrieve blob <---------+
 |                             |
 |  5. Decrypt locally         |
 |     Only user has key       |
```

### 3.8 Deploy to Node

```protobuf
rpc ApplyProxyToNode(proxy_id, node_id, revision_num, config_yaml, config_hash)
rpc UnapplyProxyFromNode(proxy_id, node_id)
rpc GetAppliedProxies(node_id)
```

- `revision_num=0`: Use `config_yaml` directly
- `revision_num>0`: Fetch from Hub first, then deploy

### 3.9 Hub Storage Model

Hub stores templates and proxy configs as opaque encrypted blobs:

```protobuf
message TemplateBlob {
  string id = 1;
  string user_id = 2;
  int32 encrypted_size_bytes = 3;
  int64 version = 4;
  Timestamp created_at = 5;
  Timestamp expires_at = 6;
  bool expired = 7;
}
```

---

## 4. CLI Commands

### 4.1 Local Proxy Management

```bash
# Import YAML file into CLI management
nitella proxy import <file.yaml> [--name "My Proxy"]

# List local proxies
nitella proxy list [--local | --remote | --all]

# Show proxy details
nitella proxy show <proxy-id> [--revision N]

# Edit proxy (opens $EDITOR or $VISUAL)
nitella proxy edit <proxy-id>

# Validate proxy config
nitella proxy validate <proxy-id>

# Export to file
nitella proxy export <proxy-id> [--output file.yaml]

# Delete local proxy
nitella proxy delete <proxy-id> [--remote]
```

### 4.2 Hub Sync

```bash
# Push to Hub (creates new revision)
nitella proxy push <proxy-id> [-m "Added rate limiting"]

# Pull from Hub
nitella proxy pull <proxy-id> [--revision N]

# List revisions
nitella proxy history <proxy-id>

# Diff between revisions
nitella proxy diff <proxy-id> [--rev1 N] [--rev2 M]

# Flush old revisions (keep only N most recent)
nitella proxy flush <proxy-id> [--keep N]
```

### 4.3 Deploy to Node

```bash
# Apply proxy config to node
nitella proxy apply <proxy-id> <node-id>

# Check applied proxies on node
nitella proxy status <node-id>

# Remove proxy from node
nitella proxy unapply <proxy-id> <node-id>
```

---

## 5. Mobile App

Templates are managed from the Templates screen, which has two tabs: **My Templates** and **Public Templates**.

### Features

- **Create Template** — Capture a node's current proxy + rule config
- **Apply to Node** — Deploy template to a target node (with optional overwrite)
- **YAML Import/Export** — Manual YAML editing via clipboard
- **Tags** — Organize templates with searchable tags

### Template Display

Each template card shows:
- Name and description
- Proxy count
- Tags
- Author fingerprint

---

## 6. Security

### What Hub CAN See

- `proxy_id` (UUID) — Required for routing
- `routing_token` — Blind identifier
- `revision_num` — Sequence number
- `size_bytes` — For quota enforcement
- `created_at`, `updated_at` — Timestamps

### What Hub CANNOT See

- Proxy name and description
- Commit messages
- Configuration content (listen addresses, backends, rules)
- Rule expressions
- Any user-identifiable information

### Encryption

- **Algorithm**: X25519 ECDH + AES-256-GCM
- **Key**: Ed25519 private key (derived from BIP-39 mnemonic)
- **AAD**: Includes proxy_id + revision_num for binding
- **Signature**: Ed25519 signature for authenticity
