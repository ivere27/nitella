# Nitella CLI User Guide

A comprehensive guide for users running the `nitella` CLI on desktop or server.

## Table of Contents

- [What is Nitella?](#what-is-nitella)
- [Design Philosophy](#design-philosophy)
- [Pros & Cons](#pros--cons)
- [Getting Started](#getting-started)
- [Connecting to a Hub](#connecting-to-a-hub)
- [Pairing Nodes](#pairing-nodes)
- [Managing Nodes](#managing-nodes)
- [Managing Proxies](#managing-proxies)
- [Rule Engine](#rule-engine)
- [Approval Workflow](#approval-workflow)
- [GeoIP](#geoip)
- [Mock Services & Honeypots](#mock-services--honeypots)
- [Monitoring](#monitoring)
- [Proxy Config Versioning](#proxy-config-versioning)
- [Local Mode](#local-mode)
- [Identity Management](#identity-management)
- [Encrypted Logs](#encrypted-logs)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Environment Variables](#environment-variables)
- [Troubleshooting](#troubleshooting)

---

## What is Nitella?

Nitella is a mobile-controlled Layer 4 (TCP) reverse proxy with zero-trust architecture. It protects any TCP service — SSH, RDP, databases, HTTP, and more — by placing an intelligent proxy in front of your backend that you manage from your phone or CLI.

The core concept: a **Hub** acts as a blind relay between your control device (CLI or mobile app) and your proxy nodes. All commands are end-to-end encrypted — the Hub operator cannot read your traffic, configuration, or even know which nodes belong to which user. Your device holds the root of trust.

---

## Design Philosophy

### Zero Trust

The Hub never sees your data. All commands and responses are encrypted using X25519 ECDH + AES-256-GCM before leaving your device. The Hub only relays opaque encrypted blobs and routing tokens — it cannot decrypt, read, or correlate anything about your setup.

### Mobile as Root CA

Your phone (or CLI) generates and holds the master Ed25519 private key. This key signs all node certificates during pairing, creating a certificate chain where your device is the root of trust. Identity is derived from a BIP-39 mnemonic — 12 or 24 words that can recover your entire setup.

### P2P First

When your control device and proxy nodes are reachable directly, Nitella establishes WebRTC data channels for command and control traffic, bypassing the Hub entirely. This means lower latency, no rate limits, and no dependency on Hub availability. If P2P fails (NAT, firewall), the Hub relay is used as a fallback.

### Defense in Depth

Nitella layers multiple security mechanisms:
- **GeoIP rules** — block by country, city, or ISP
- **mTLS** — certificate-based client authentication
- **Approval workflow** — real-time approve/deny from your phone
- **Honeypots & tarpits** — waste attacker resources with fake services

---

## Pros & Cons

| Pros | Cons |
|------|------|
| E2E encrypted — Hub operator can't read your data | Requires Hub infrastructure for remote management |
| GeoIP + IP + TLS rules in one place | Layer 4 only — no HTTP path/header inspection |
| Real-time approval for connections | Slightly higher latency vs raw iptables |
| Honeypot/tarpit built in | GeoIP accuracy depends on MaxMind data |
| BIP-39 identity — recoverable from mnemonic | Initial setup more complex than a simple firewall |
| P2P mode — works without Hub for local networks | P2P requires UDP connectivity for WebRTC |
| Hub migration is seamless — no re-pairing needed | Nodes need to be restarted with new Hub address |

---

## Getting Started

### Building

```bash
# Build all binaries
make build

# Or build individually
go build -o nitella ./cmd/nitella      # CLI client
go build -o nitellad ./cmd/nitellad    # Proxy daemon (node)
```

### First Launch — Identity Creation

On first launch, the CLI automatically creates your cryptographic identity. You will be prompted to:

1. **Set a passphrase** (optional but recommended) — encrypts your private key at rest
2. **Save your recovery phrase** — 12 or 24 BIP-39 words displayed once

Your identity is managed by the Go backend service and stored in `~/.nitella/` (configurable with `--data-dir`).

### Recovery Phrase

After identity creation, you will be shown a BIP-39 mnemonic (12 or 24 words). **Write this down and store it securely** — it can recover your entire identity if you lose your device.

```
Your recovery phrase:

  apple banana cherry dolphin echo foxtrot
  guitar hotel india juliet kilo lima

Store this phrase in a safe place. Anyone with this phrase
can recover your identity and control all paired nodes.
```

### Passphrase Strength

The CLI analyzes your passphrase strength and provides feedback:

```
Passphrase strength: Strong
  Length: 24 characters
  Entropy: ~78 bits
  Estimated crack time: centuries (offline attack)
```

---

## Connecting to a Hub

The Hub enables remote management of nodes from anywhere. It acts as a blind relay — all your data passes through it encrypted.

### Configure Hub Address

```bash
nitella config set hub hub.example.com:50052
```

### First Connection

```bash
nitella login
```

On first connection, the CLI verifies the Hub's TLS certificate:

**Hub with a well-known CA (Let's Encrypt, etc.):**
```
+----------------------------------------------------------+
|              HUB CERTIFICATE VERIFIED                     |
+----------------------------------------------------------+
|  Hub:        hub.example.com:50052                        |
|  Subject:    hub.example.com                              |
|  Issuer:     Let's Encrypt Authority X3                   |
+----------------------------------------------------------+
```

**Self-hosted Hub (self-signed):**
```
+----------------------------------------------------------+
|    FIRST CONNECTION - VERIFY HUB IDENTITY                 |
+----------------------------------------------------------+
|  Hub:        hub.example.com:50052                        |
|  Subject:    Nitella Hub                                  |
|  SHA-256:    a1b2c3d4...                                  |
+----------------------------------------------------------+
|  This Hub uses a self-signed certificate.                 |
|  Verify fingerprint matches Hub operator's published      |
|  value before accepting!                                  |
+----------------------------------------------------------+
Trust this Hub and save certificate? (yes/no):
```

After verification, the certificate is saved locally and future connections are verified automatically.

### Registration

```bash
nitella register [invite_code]
```

Creates your account on the Hub using your existing identity. The Hub never receives your private key — only your public key and routing information.

---

## Pairing Nodes

Pairing connects a `nitellad` proxy node to your CLI so you can manage it remotely. During pairing, a key exchange occurs: the node generates a keypair and CSR, your CLI signs it with your Root CA, and both sides establish shared encryption keys.

### PAKE Pairing (via Hub)

PAKE (Password-Authenticated Key Exchange) pairing works over the Hub. The node generates a short pairing code that you enter in your CLI.

**On the node:**
```bash
nitellad --hub hub.example.com:50052 --pair
# Displays: Pairing code: 7-tiger-castle
```

**On your CLI:**
```bash
nitella pair
# Enter pairing code: 7-tiger-castle
```

Both sides derive a shared key from the code and exchange encrypted certificates. Emoji fingerprints are displayed for visual verification.

### Offline / QR Pairing (Air-Gapped)

For nodes without Hub access, use offline pairing:

**On the node:**
```bash
nitellad --hub hub.example.com:50052 --pair-offline
# Displays QR code or JSON CSR on screen
```

**On your CLI (or mobile app):**
- Scan the QR code with your phone camera, or
- Copy the JSON CSR text and paste it into the CLI

The CLI signs the CSR and returns the signed certificate to the node.

**With Web UI (recommended for Docker):**
```bash
docker run -p 8888:8888 nitellad \
  --hub hub.example.com:50052 \
  --pair-offline --pair-port :8888 --pair-timeout 5m
```

Then open `https://localhost:8888` in your browser and follow the guided pairing flow with CPACE word verification.

### What Happens During Pairing

1. Node generates an Ed25519 keypair and Certificate Signing Request (CSR)
2. CLI and node establish a shared secret via PAKE or QR exchange
3. CLI signs the CSR with your Root CA
4. CLI generates a routing token: `HMAC-SHA256(nodeID, userSecret)`
5. Node receives the signed certificate and connects to Hub with mTLS
6. CLI stores the routing token locally for future communication

---

## Managing Nodes

### List All Paired Nodes

```bash
nitella nodes
```

Shows all nodes with their status (online/offline), connection type (P2P/Hub), and last seen time.

### Node Details

```bash
nitella node <node-id> status
```

Shows detailed node information including active proxies, connection statistics, and P2P connectivity.

### Node Rules

```bash
nitella node <node-id> rules
```

### Node Metrics

```bash
nitella node <node-id> metrics
```

### Node Connections

```bash
nitella node <node-id> conn
nitella node <node-id> conn close <conn-id>
nitella node <node-id> conn closeall
```

### P2P vs Hub Connectivity

When you issue commands, the CLI tries P2P first:
1. **P2P (WebRTC)** — Direct connection via DTLS, lowest latency, no Hub dependency
2. **Hub Relay** — Falls back to Hub if P2P fails, all traffic E2E encrypted

You can configure STUN servers for P2P NAT traversal:
```bash
nitella --stun stun:stun.cloudflare.com:3478 node <node-id> status
```

Or via environment variable:
```bash
export NITELLA_STUN="stun:global.stun.twilio.com:3478"
```

---

## Managing Proxies

Proxies are TCP listeners on your nodes that forward traffic to backend services. Each proxy has a default action and optional rules for fine-grained control.

### Create a Proxy

```bash
nitella proxy create <listen-addr> <backend-addr>
```

Example:
```bash
# Create a proxy on port 8080 forwarding to a local web server
nitella proxy create :8080 192.168.1.10:80

# Create a proxy with a name
nitella proxy create :3389 192.168.1.20:3389 --name "RDP Access"
```

### Default Actions

When creating a proxy, you can set a default action that applies when no rules match:

| Action | Behavior |
|--------|----------|
| `allow` | Forward to default backend (blacklist mode) |
| `block` | Reject connection (whitelist mode) |
| `mock` | Respond with a fake service banner |
| `require_approval` | Hold connection and request real-time approval |

```bash
# Whitelist mode — block by default, allow specific IPs via rules
nitella proxy create :22 192.168.1.1:22 --action block

# Approval mode — every connection needs manual approval
nitella proxy create :3306 10.0.0.1:3306 --action require_approval
```

### List Proxies

```bash
nitella proxy list
```

### View Proxy Status

```bash
nitella proxy status <node-id>
```

### Delete a Proxy

```bash
nitella proxy delete <proxy-id>
```

### Enable / Disable

```bash
nitella proxy enable <proxy-id>
nitella proxy disable <proxy-id>
```

---

## Rule Engine

Rules define how individual connections are handled based on conditions like source IP, geographic location, or TLS certificate attributes. Rules are evaluated in priority order — highest priority number first.

### Add a Rule

```bash
nitella rule add <proxy-id> <action> <condition>
```

Examples:
```bash
# Allow a specific IP
nitella rule add proxy1 allow --ip 10.0.0.50

# Block a CIDR range
nitella rule add proxy1 block --ip 192.168.0.0/16

# Allow only Korean IPs
nitella rule add proxy1 allow --country KR

# Block a specific ISP
nitella rule add proxy1 block --isp "Amazon"

# Require approval for after-hours connections
nitella rule add proxy1 require_approval --time "18:00-09:00"
```

### Condition Types

| Condition | Description | Example Value |
|-----------|-------------|---------------|
| `source_ip` | Match by IP address or CIDR | `192.168.1.0/24`, `1.2.3.4` |
| `geo_country` | Match by country code | `KR`, `US`, `JP` |
| `geo_city` | Match by city name | `Seoul`, `Tokyo` |
| `geo_isp` | Match by ISP/organization | `Amazon`, `Google Cloud` |
| `tls_fingerprint` | Match by TLS certificate fingerprint | `SHA256:abc123...` |
| `tls_cn` | Match by TLS Common Name | `admin@company.com` |
| `tls_cert_present` | Match if client presented a certificate | `true` |
| `tls_serial` | Match by certificate serial number | `1234567890` |
| `time_range` | Match by time of day | `18:00-09:00` |

### Priority System

Rules are evaluated from highest to lowest priority number. The first matching rule determines the action.

```bash
# High priority — always allow the admin
nitella rule add proxy1 allow --ip 10.0.0.1 --priority 200

# Medium priority — block datacenter IPs
nitella rule add proxy1 block --isp "AWS" --priority 100

# Low priority — require approval for everything else
# (handled by proxy default action)
```

### List Rules

```bash
nitella rule list <proxy-id>
```

### Remove a Rule

```bash
nitella rule remove <rule-id>
```

### Global Rules

Global rules apply across **all proxies** on a node. Useful for emergency blocking or always-allowing trusted IPs.

```bash
# Block an IP across all proxies
nitella block <ip>
nitella block 1.2.3.4                # Block permanently
nitella block 1.2.3.4 3600           # Block for 1 hour

# Allow an IP across all proxies
nitella allow <ip>
nitella allow 10.0.0.50              # Allow permanently
nitella allow 10.0.0.50 600          # Allow for 10 minutes

# List active global rules
nitella global-rules

# Remove a global rule
nitella global-rules remove <id>
```

**Note:** Global ALLOW prevents blocking but does **not** bypass `require_approval`. Use per-proxy rules to fully whitelist an IP.

---

## Approval Workflow

When a proxy uses `require_approval` as its default action (or a rule triggers it), incoming connections are held pending until you approve or deny them.

### How It Works

1. A connection arrives at a proxy configured with `require_approval`
2. The node sends an encrypted alert to your CLI (via Hub or Direct)
3. You see the alert with source IP, GeoIP info, and destination
4. You approve (with a retention mode and duration) or deny the connection
5. The decision is cached — future connections from the same IP are auto-handled for the specified duration

### Real-Time Alerts

Alerts appear automatically in your CLI while you're using it:

```
nitella> status
  3 proxies running, 12 connections active

================================================================
  APPROVAL REQUIRED (req: abc123)
  Source: 1.2.3.4 (CN, Beijing, China Telecom)
  Dest:   prod-db:5432
  Proxy:  mysql-proxy

  -> approve abc123 [duration]  or  -> deny abc123
================================================================
```

### Stream Alerts

To continuously receive approval alerts in the background:

```bash
nitella alerts
```

Alerts stream automatically until Ctrl+C.

### List Pending Requests

```bash
nitella pending
```

### Approve a Connection

```bash
nitella approve <request-id> [duration]              # Cache mode (default)
nitella approve cache <request-id> [duration]        # Explicit cache mode
nitella approve once <request-id> [duration]         # Connection-only mode
```

**Retention modes:**
- `cache` (default) — Decision cached for duration; future connections from same IP auto-handled
- `once` / `single` / `conn` / `connection` — Decision applies only to this connection

**Duration formats:** `10s`, `1m`, `5m`, `10m`, `1h`, `1d`, `1w`, `1y`

Default duration: **300 seconds (5 minutes)** for cache mode.

A duration of `0` means connection-only (no caching).

### Deny a Connection

```bash
nitella deny <request-id>                            # Connection-only (default)
nitella deny once <request-id> [duration] [reason]   # Explicit connection-only
nitella deny cache <request-id> [duration] [reason]  # Cache mode
```

### Fallback Actions

When a connection is denied or times out, a fallback action can be triggered:

| Fallback | Behavior |
|----------|----------|
| `close` (default) | Immediately close connection |
| `mock` | Serve a mock response (HTTP 403, SSH tarpit, etc.) |

---

## GeoIP

Nitella includes a full GeoIP system for looking up geographic and ISP information for IP addresses. It powers the GeoIP rule conditions and provides useful context in approval requests.

### Quick Lookup

```bash
nitella lookup <ip>
```

Example:
```bash
nitella lookup 8.8.8.8
# Country: United States (US)
# City: Mountain View
# ISP: Google LLC
# ASN: 15169
```

### GeoIP Status

```bash
nitella geoip status
```

### GeoIP Configuration

```bash
nitella geoip config local <city_db> [isp_db]
nitella geoip config remote <provider> [api_key]
```

### Lookup Strategy

GeoIP uses a multi-layered lookup strategy for fast and reliable results:

```
L1 Cache (in-memory) -> L2 Cache (SQLite) -> Local DB (MaxMind) -> Remote API (ip-api)
```

1. **L1 Cache** — In-memory LRU cache, fastest, default 10,000 entries
2. **L2 Cache** — SQLite persistent cache, survives restarts, configurable TTL
3. **Local DB** — MaxMind GeoLite2 databases (City + ASN), local lookups
4. **Remote API** — HTTP providers (ipwhois, ip-api) as last resort

---

## Mock Services & Honeypots

Mock services respond with fake protocol banners. They're useful for:

- **Honeypots** — detect scanning and attack attempts on common ports
- **Tarpits** — waste attacker time with slow, endless responses
- **Testing** — simulate services without running real backends

### Available Presets

| Preset | Description |
|--------|-------------|
| `ssh` | OpenSSH banner, accepts auth (fails all) |
| `ssh-tarpit` | Extremely slow SSH auth — wastes attacker time (endlessh-style) |
| `http` | Basic HTTP 200 response |
| `http-403` | HTTP 403 Forbidden |
| `http-404` | HTTP 404 Not Found |
| `rdp` | RDP X.224 negotiation banner |
| `mysql` | MySQL handshake + access denied |
| `mssql` | TDS pre-login response |
| `redis` | Redis RESP protocol with NOAUTH |
| `smtp` | ESMTP with capabilities |
| `telnet` | Telnet negotiation + login prompt |
| `raw` | Echo back client data or custom payload |

### Deploying a Honeypot

Create a proxy with `mock` as the default action:

```bash
nitella proxy create :22 --action mock --mock ssh-tarpit --name "SSH Honeypot"
```

Or in YAML config:
```yaml
entrypoints:
  ssh-honeypot:
    address: ":22"
    default_action: mock
    default_mock: ssh-tarpit
```

### What Tarpits Do

Tarpits are designed to waste attacker resources:

| Protocol | Tarpit Behavior |
|----------|-----------------|
| SSH | Sends endless random lines before the SSH banner (endlessh-style) |
| MySQL | Infinite authentication loop with rotating error messages |
| Redis | PING works, AUTH always fails, QUIT is ignored |
| SMTP | Accepts entire mail flow but never delivers |
| HTTP | Slowloris-style slow drip of a large fake page |
| Telnet | Endless login prompts |

Drip mode sends data byte-by-byte with configurable delays, tying up scanner connections waiting for complete banners.

---

## Monitoring

### Live Connection Events

```bash
nitella stream
```

Streams connection events in real-time — new connections, disconnections, rule matches, approval requests, and more.

### Real-Time Metrics

```bash
nitella metrics [interval]
```

Shows real-time metrics including connection count, bandwidth, rule hit rates, and GeoIP breakdowns.

### Active Connections

```bash
nitella conn
```

Lists all currently active connections with source IP, GeoIP info, duration, and bandwidth.

### Close Connections

```bash
# Close a specific connection
nitella conn close <proxy-id> <connection-id>

# Close all active connections
nitella conn closeall [proxy-id]
```

---

## Proxy Config Versioning

Proxy configs can be version-controlled and stored on the Hub with E2E encryption. This enables revision history, diff between versions, and consistent deployment across nodes.

### Import a Config File

```bash
nitella proxy import <file.yaml> [--name "My Proxy"]
```

Imports a YAML configuration file into CLI management, stored locally at `~/.nitella/proxies/`.

### Push to Hub

```bash
nitella proxy push <proxy-id> [-m "Added rate limiting"]
```

Encrypts and pushes the configuration as a new revision to the Hub. The Hub stores the encrypted blob — it cannot read the configuration content.

### Revision History

```bash
nitella proxy history <proxy-id>
```

### Diff Between Revisions

```bash
nitella proxy diff <proxy-id> [--rev1 N] [--rev2 M]
```

Shows a unified diff between two revisions (default: local vs latest Hub revision).

### Pull from Hub

```bash
nitella proxy pull <proxy-id> [--revision N]
```

### Validate Config

```bash
nitella proxy validate <proxy-id>
```

Checks checksum, headers, and YAML validity.

### Apply to a Node

```bash
nitella proxy apply <proxy-id> <node-id>
```

Fetches the configuration, decrypts it, re-encrypts for the target node, and sends it via the Hub.

### Check Applied Proxies

```bash
nitella proxy status <node-id>
```

### Remove from Node

```bash
nitella proxy unapply <proxy-id> <node-id>
```

### Export

```bash
nitella proxy export <proxy-id> [--output file.yaml]
```

### Edit

```bash
nitella proxy edit <proxy-id>
```

Opens the proxy configuration in your `$EDITOR` (falls back to `$VISUAL`).

### Flush Old Revisions

```bash
nitella proxy flush <proxy-id> [--keep N]
```

---

## Local Mode

The CLI supports a **local mode** for directly managing a `nitellad` node on the same machine or local network, without going through a Hub.

### Connecting Locally

```bash
nitella --local --addr localhost:50051 --tls-ca /path/to/admin_ca.crt
```

Flags:
- `--local` — Enable local mode
- `--addr <host:port>` — Address of the nitellad admin API (default: `localhost:50051`)
- `--token <TOKEN>` — Authentication token (env: `NITELLA_TOKEN`)
- `--tls-ca <PATH>` — TLS CA certificate for the admin API (env: `NITELLA_TLS_CA`, **required**)

When using `--local`, the CLI registers the node as a "direct node" in the backend, then all commands use the same backend RPC interface.

### Local Mode Commands

Local mode supports proxy, rule, connection, and monitoring commands directly against the node:

```bash
# Proxy management
nitella --local proxy create <addr> <backend> [name]
nitella --local proxy delete <proxy-id>
nitella --local proxy enable <proxy-id>
nitella --local proxy disable <proxy-id>
nitella --local proxy update <proxy-id> [--backend <addr>] [--name <name>]
nitella --local list

# Rules
nitella --local rule add <proxy-id> <allow|block> <ip>
nitella --local rule list <proxy-id>
nitella --local rule remove <proxy-id> <rule-id>

# Connections
nitella --local conn [proxy-id]
nitella --local conn close <proxy-id> <conn-id>
nitella --local conn closeall [proxy-id]

# Global rules
nitella --local block <ip> [duration]
nitella --local allow <ip> [duration]
nitella --local global-rules [list | remove <rule-id>]

# Approvals
nitella --local approvals [list | cancel <key> [--close-connections]]

# Monitoring
nitella --local stream
nitella --local metrics [interval]
nitella --local status [proxy-id]

# GeoIP
nitella --local lookup <ip>
nitella --local geoip status
nitella --local geoip config local <city_db> [isp_db]
nitella --local geoip config remote <provider>

# Restart all listeners
nitella --local restart

# Debug
nitella --local debug [runtime | grpc | goroutine]
```

---

## Identity Management

Your cryptographic identity is the foundation of all Nitella operations.

### View Identity

```bash
nitella identity
```

Shows your emoji fingerprint, certificate subject, and key status.

### Export CA Certificate

```bash
nitella identity export-ca
```

Exports your Root CA certificate for sharing with others or for manual node configuration.

---

## Encrypted Logs

Nodes can push encrypted log entries to the Hub for centralized storage. The Hub stores the encrypted blobs but cannot read the log content.

### Log Commands

```bash
# View storage statistics
nitella logs stats

# List logs for a routing token
nitella logs list <routing_token>

# Delete logs for a routing token
nitella logs delete <routing_token>

# Cleanup logs older than N days
nitella logs cleanup <days>
```

---

## Keyboard Shortcuts

The CLI includes an interactive REPL with tab completion:

| Key | Action |
|-----|--------|
| `Tab` | Auto-complete commands and arguments |
| `Up` / `Down` | Navigate command history |
| `Ctrl+C` | Cancel current input / exit |

### Tab Completion

**Hub mode commands:**
```
config, login, register, status, nodes, node, alerts, pending,
approve, deny, proxy, identity, pair, debug, help, exit
```

**Local mode commands:**
```
status, list, ls, proxy, rule, conn, connections, block, allow,
global-rules, approvals, stream, metrics, debug, restart, geoip,
lookup, help, exit
```

---

## Environment Variables

| Variable | Description |
|----------|-------------|
| `NITELLA_PASSPHRASE` | Key encryption passphrase (avoids interactive prompt) |
| `NITELLA_TOKEN` | Authentication token for local mode admin API |
| `NITELLA_TLS_CA` | Path to TLS CA certificate for local mode |
| `NITELLA_HUB` | Hub server address (requires `--override-backend-config`) |
| `NITELLA_HUB_TOKEN` | Hub authentication token |
| `NITELLA_STUN` | STUN server URL for P2P NAT traversal (requires `--override-backend-config`) |
| `EDITOR` | Editor for `proxy edit` command |
| `VISUAL` | Fallback editor for `proxy edit` command |

---

## Troubleshooting

### Can't Connect to Hub

1. **Check Hub is reachable:**
   ```bash
   curl https://hub.example.com:50052/health
   ```
2. **Verify Hub address** in config:
   ```bash
   nitella config
   ```
3. **Check TLS certificate** — if the Hub uses a self-signed cert, verify you accepted the fingerprint on first connection
4. **Clock synchronization** — clocks must be within 60 seconds for replay protection to work

### Node Shows Offline

1. **Check the node is running:**
   ```bash
   systemctl status nitellad   # or check the process
   ```
2. **Check Hub connectivity from the node:**
   ```bash
   nitellad --hub hub.example.com:50052 --check
   ```
3. **Verify node certificate hasn't expired**
4. **Check firewall** — the node needs outbound access to the Hub's gRPC port

### P2P Connection Failing

1. **Check firewall allows UDP** — WebRTC requires UDP connectivity
2. **Try a different STUN server:**
   ```bash
   nitella --stun stun:stun.cloudflare.com:3478 node <id> status
   ```
3. **Behind restrictive NAT?** — Some corporate networks block UDP entirely; fall back to Hub relay mode
4. **Disable P2P if not needed:**
   ```bash
   nitellad --hub hub.example.com:50052 --hub-p2p=false
   ```

### Firewall / Docker Bridge Issues

If your node runs inside Docker, make sure:
- The backend address is reachable from inside the container
- Use Docker network names instead of `localhost` for backend addresses
- Map the proxy listen ports with `-p` flags

### TLS Certificate Issues

- **Certificate expired:** Re-pair the node to issue a new certificate
- **Certificate mismatch:** Ensure both CLI and node reference the same CA
- **Self-signed Hub:** Verify the Hub fingerprint matches what the operator published

### Approval Notifications Not Arriving

1. **Check connection to Hub** — alerts flow through Hub or Direct connection
2. **Verify CLI is running** — alerts only display in an active CLI session
3. **Check proxy action** — ensure the proxy or a rule uses `require_approval`

### Hub Migration

If your Hub provider changes, migration is straightforward because your identity is portable:

```bash
# 1. Export configs from old Hub
nitella proxy export <proxy-id> --output backup.yaml

# 2. Configure new Hub
nitella config set hub newhub.example.com:50052

# 3. Register with new Hub
nitella register

# 4. Push configs
nitella proxy import backup.yaml
nitella proxy push <proxy-id>

# 5. Restart nodes with new Hub address
# (on each node server)
nitellad --hub newhub.example.com:50052
```

No re-pairing is needed — node certificates are portable across Hubs.
