# Approval System

Real-time connection approval for zero-trust access control.

## Overview

When a proxy uses `require_approval` action, incoming connections are held pending until you approve or deny them via CLI or mobile app.

**Key Characteristics:**
- **Runtime-only**: Decisions cached in memory (cleared on restart)
- **Time-bounded**: Connections destroyed when approval expires
- **Push-based**: Alerts pushed to user in real-time
- **E2E Encrypted**: Hub cannot read approval content
- **TLS Session Binding**: Cache entries bound to TLS session ID

## Configuration

### Proxy Default Action

```yaml
proxy:
  id: "mysql-proxy"
  listen: ":3306"
  default_action: require_approval
  default_backend: "10.0.0.1:3306"
```

### Rule-Based Approval

```yaml
rules:
  - name: "Approve Unknown Countries"
    priority: 100
    action: require_approval
    conditions:
      - type: geo_country
        op: not_in
        value: "US,CA,GB,JP,KR"

  - name: "Approve After Hours"
    priority: 90
    action: require_approval
    conditions:
      - type: time_range
        op: in
        value: "18:00-09:00"
```

**Evaluation order**: Rules (by priority) -> Default Action

## Architecture

### Hub Mode

```
Node                         Hub                        CLI/Mobile
  |                           |                              |
  |  1. Connection arrives    |                              |
  |     (REQUIRE_APPROVAL)    |                              |
  |                           |                              |
  |  2. Encrypted alert ------>                              |
  |                           |  3. Forward alert ----------->
  |                           |                              |
  |                           |                    4. User sees alert
  |                           |                       (Source IP, Geo, etc.)
  |                           |                              |
  |                           |<----- 5. Encrypted decision -|
  |<-- 6. Forward decision ---|                              |
  |                           |                              |
  |  7. Allow/Block + Cache   |                              |
```

### Direct Node Mode

```
Node <=============================================> CLI/Mobile
              Direct mTLS connection

 No Hub dependency     No rate limits
 Lower latency         Works on LAN/VPN
```

Direct nodes are standalone `nitellad` instances connected without Hub. Approval operations use:
- `COMMAND_TYPE_LIST_ACTIVE_APPROVALS` — Fetch pending approvals directly from node
- `COMMAND_TYPE_RESOLVE_APPROVAL` — Send decision directly to node

## Approval Request

When a connection triggers approval, the following information is captured:

| Field | Description |
|-------|-------------|
| `request_id` | Composite format: `nodeID:uniqueID` |
| `node_id`, `node_name` | Source node |
| `proxy_id`, `proxy_name` | Proxy that triggered approval |
| `source_ip`, `source_port` | Client connection info |
| `dest_addr` | Target backend address |
| `rule_id`, `rule_name` | Rule that triggered approval (if any) |
| `geo` | GeoIP info (country, city, ISP) |
| `timestamp` | When request was created |
| `tls_cn`, `tls_fingerprint` | TLS client certificate info (if present) |

## CLI Commands

### Approve

```bash
nitella approve <request_id> [duration]              # Cache mode (default)
nitella approve cache <request_id> [duration]        # Explicit cache mode
nitella approve once <request_id> [duration]         # Connection-only mode
```

**Retention modes:**
- `cache` (default) — Decision cached for duration; future connections from same IP auto-handled
- `once` / `single` / `conn` / `connection` — Decision applies only to this connection

**Duration formats:** `10s`, `1m`, `5m`, `10m`, `1h`, `1d`, `1w`, `1y`

Default duration: **300 seconds (5 minutes)** when using cache mode.

### Deny

```bash
nitella deny <request_id>                            # Connection-only (default)
nitella deny once <request_id> [duration] [reason]   # Explicit connection-only
nitella deny cache <request_id> [duration] [reason]  # Cache mode
```

Default retention for deny: **CONNECTION_ONLY** (once).

### Other Commands

```bash
nitella pending                   # List pending approval requests
nitella alerts                    # Stream approval alerts in real-time
```

### Block / Allow (Global Rules)

Quick IP blocking/allowing across ALL proxies on a node:

```bash
nitella block <ip> [duration_seconds]    # Block permanently or with duration
nitella allow <ip> [duration_seconds]    # Allow permanently or with duration
nitella global-rules                     # List active global rules
nitella global-rules remove <id>         # Remove a rule
```

**Important**: Global ALLOW prevents blocking but does NOT bypass `require_approval`. Use per-proxy rules to fully whitelist an IP.

## Mobile App

### Approve Options

Tap the green **Approve** dropdown:

| Option | Effect |
|--------|--------|
| Approve once | Allow this single connection (CONNECTION_ONLY) |
| Approve 1 hour | Cache approval for 1 hour |
| Approve 24 hours | Cache approval for 24 hours |
| Approve permanently | Create a permanent allow rule |

### Deny Options

Tap the red **Deny** dropdown:

| Option | Effect |
|--------|--------|
| Deny once | Reject this connection, no rule created |
| Block IP | Deny + create a block rule for the source IP |
| Block ISP | Deny + create a block rule for the source ISP |

The `DenyBlockType` enum controls block rule creation:

| Type | Description |
|------|-------------|
| `DENY_BLOCK_TYPE_NONE` | Just deny, no rule |
| `DENY_BLOCK_TYPE_IP` | Deny + create block rule for source IP via `BlockIP()` |
| `DENY_BLOCK_TYPE_ISP` | Deny + create block rule for source ISP via `BlockISP()` |

## Retention Modes

| Mode | Behavior |
|------|----------|
| `CACHE` | Decision cached in approval cache for `duration_seconds`. New connections from same source IP + rule within window use the cached decision. Default duration: 300 seconds. |
| `CONNECTION_ONLY` | Decision applies only to the pending connection. `duration_seconds` is max lifetime (0 = until connection closes). Not cached for other connections. |

## Duration

| Value | Description |
|-------|-------------|
| `0` | Session only (expires when connection closes) |
| `10` | 10 seconds |
| `60` | 1 minute |
| `300` | 5 minutes (default for cache mode) |
| `600` | 10 minutes |
| `3600` | 1 hour |
| `86400` | 24 hours |
| `-1` | Permanent (no expiry) |

When a cached approval expires, all connections using it are closed immediately.

## Approval Cache

The node maintains an approval cache for time-limited decisions.

### Cache Key

```
sourceIP\x00ruleID\x00tlsSessionID
```

The cache key includes the TLS session ID for strict session binding — approvals are not transferable across different TLS sessions.

### Cache Behavior

- Background cleanup loop runs periodically
- Entries expire after `duration_seconds`
- Each entry tracks live connections with byte counters
- Accumulated stats from closed connections are preserved

### DoS Protection

| Protection | Default | Effect |
|------------|---------|--------|
| Per-IP pending limit | Configurable | Single attacker limited |
| Global pending limit | Configurable | Total pending requests capped |
| Per-proxy pending limit | Configurable | Per-proxy cap |
| Approval timeout | Configurable | Requests auto-expire |
| Immediate cleanup | - | Slots freed when connection closes |

## Approval History

Decisions are persisted to `~/.nitella/approvals/history.json` for audit purposes.

Each history entry records:

| Field | Description |
|-------|-------------|
| `request_id` | Original request ID |
| `node_id`, `node_name` | Source node |
| `proxy_id`, `proxy_name` | Proxy involved |
| `source_ip`, `dest_addr` | Connection endpoints |
| `geo` | GeoIP data |
| `action` | `APPROVED`, `DENIED`, or `EXPIRED` |
| `duration_seconds` | Duration applied |
| `block_type` | Block rule type if created (IP/ISP) |
| `rule_id` | Created rule ID if applicable |
| `decided_at` | Decision timestamp |

History is capped at 1000 entries (most recent first) and can be cleared via `ClearApprovalHistory`.

## Security

### E2E Encryption

All approval traffic through Hub is encrypted:

- **Node -> Hub -> CLI**: Alert encrypted with CLI's public key
- **CLI -> Hub -> Node**: Decision encrypted with Node's public key
- **Hub sees**: Only encrypted blobs and routing metadata
- **Hub cannot**: Read content, forge decisions, or replay old decisions

Decisions are cryptographically signed — nodes verify the signature before accepting.

### TLS Session Binding

Approvals are bound to TLS sessions via the cache key (`sourceIP\x00ruleID\x00tlsSessionID`). If a TLS session ID is provided, it must match exactly — there is no fallback.

### Command Types

| Command | Value | Description |
|---------|-------|-------------|
| `COMMAND_TYPE_RESOLVE_APPROVAL` | 30 | Send approval/denial decision to node |
| `COMMAND_TYPE_LIST_ACTIVE_APPROVALS` | 70 | List active approvals (direct nodes) |
| `COMMAND_TYPE_CANCEL_APPROVAL` | 71 | Cancel an active approval (direct nodes) |

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| "No ApprovalManager" | Node not connected to Hub or Direct | Configure `--hub-addr` or use Direct Connect |
| "Approval timeout" | User didn't respond in time | Respond faster or increase timeout |
| "Signature verification failed" | Wrong key or tampering | Check key config |
| Connection closed unexpectedly | Approval timer expired | Use longer duration |
