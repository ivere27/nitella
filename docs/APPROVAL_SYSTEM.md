# Approval System

Real-time connection approval for zero-trust access control.

## Overview

When a proxy uses `require_approval` action, incoming connections are held pending until you approve or deny them via CLI or mobile app.

**Key Characteristics:**
- **Runtime-only**: Decisions cached in memory (cleared on restart)
- **Time-bounded**: Connections destroyed when approval expires
- **Push-based**: Alerts pushed to user in real-time
- **E2E Encrypted**: Hub cannot read approval content
- **Rate-limited**: Hub mode enforces tier-based limits; P2P has no limits

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

**Evaluation order**: Rules (by priority) → Default Action

## Architecture

### Hub Mode

```
Node                         Hub                        CLI/Mobile
  │                           │                              │
  │  1. Connection arrives    │                              │
  │     (REQUIRE_APPROVAL)    │                              │
  │                           │                              │
  │  2. Encrypted alert ─────▶│                              │
  │                           │  3. Forward alert ──────────▶│
  │                           │                              │
  │                           │                    4. User sees alert
  │                           │                       (Source IP, Geo, etc.)
  │                           │                              │
  │                           │◀───── 5. Encrypted decision ─│
  │◀── 6. Forward decision ───│                              │
  │                           │                              │
  │  7. Allow/Block + Cache   │                              │
```

### P2P Mode

```
Node ◀════════════════════════════════════════════▶ CLI/Mobile
              Direct Channel (DTLS encrypted)

✓ No Hub dependency    ✓ No rate limits
✓ Lower latency        ✓ Works offline (LAN)
```

### CLI Experience

Alerts appear automatically while using the CLI:

```
nitella> status
  3 proxies running, 12 connections active

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠ APPROVAL REQUIRED (req: abc123)
  Source: 1.2.3.4 (CN, Beijing, China Telecom)
  Dest:   prod-db:5432
  Proxy:  mysql-proxy

  → approve abc123 [duration]  or  → deny abc123
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

nitella> approve abc123 1h
✓ Approved for 1 hour
```

## CLI Commands

### Approval

```bash
nitella approve <req_id> 1h          # Approve for 1 hour
nitella approve <req_id> 300         # Approve for 300 seconds
nitella deny <req_id>                # Deny request
nitella deny <req_id> "reason"       # Deny with reason
nitella pending                      # List pending requests
```

### Global Rules

Quick IP blocking/allowing across ALL proxies:

```bash
nitella block 1.2.3.4                # Block permanently
nitella block 1.2.3.4 3600           # Block for 1 hour
nitella allow 10.0.0.50              # Allow permanently
nitella allow 10.0.0.50 600          # Allow for 10 minutes
nitella global-rules                 # List active rules
nitella global-rules remove <id>     # Remove a rule
```

**Important**: Global ALLOW prevents blocking but does NOT bypass `require_approval`. Use per-proxy rules to fully whitelist an IP.

## Duration

| Value | Description |
|-------|-------------|
| `0` | Single connection only (no caching) |
| `60` | 1 minute |
| `3600` | 1 hour |
| `86400` | 24 hours |

When approval expires, all connections using it are closed immediately.

## Security

### E2E Encryption

All approval traffic through Hub is encrypted:

- **Node → Hub → CLI**: Request encrypted with CLI's public key
- **CLI → Hub → Node**: Decision encrypted with Node's public key
- **Hub sees**: Only encrypted blobs and routing metadata
- **Hub cannot**: Read content, forge decisions, or replay old decisions

Decisions are cryptographically signed - nodes verify the signature before accepting.

### TLS Session Binding

Approvals are bound to TLS sessions to prevent replay attacks across different connections.

### DoS Protection

The node protects against approval queue exhaustion:

| Protection | Default | Effect |
|------------|---------|--------|
| Per-IP pending limit | 10 | Single attacker limited to 10 slots |
| Global pending limit | 1000 | Total pending requests capped |
| Approval timeout | 2 min | Requests auto-expire |
| Immediate cleanup | - | Slots freed when connection closes |

## Rate Limiting (Hub Mode)

| Tier | Requests/min | Max Pending |
|------|--------------|-------------|
| Free | 600 | 20 |
| Pro | 6000 | 200 |
| Business | 60000 | 2000 |

P2P mode bypasses Hub and has no rate limits.

## Fallback Actions

When connection is blocked or times out:

| Fallback | Behavior |
|----------|----------|
| `close` (default) | Immediately close connection |
| `mock` | Serve mock response (HTTP 403, SSH tarpit, etc.) |

```yaml
proxy:
  default_action: require_approval
  fallback_action: mock
  fallback_mock: http-403
```

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| "No ApprovalManager" | Node not connected to Hub/P2P | Configure `--hub-addr` |
| "Approval timeout" | User didn't respond in time | Respond faster or increase timeout |
| "Rate limit exceeded" | Too many requests for tier | Upgrade tier or use P2P mode |
| "Signature verification failed" | Wrong key or tampering | Check key config |
| Connection closed unexpectedly | Approval timer expired | Use longer duration |
