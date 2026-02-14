# Nitella Reverse Proxy Architecture

**A security-first Layer 4 (TCP) reverse proxy with intelligent traffic routing, statistics, and mock services.**

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Deployment Modes](#deployment-modes)
- [Listener Management](#listener-management)
- [Rule Engine](#rule-engine)
- [Mock Services](#mock-services)
- [GeoIP Integration](#geoip-integration)
- [Statistics & Monitoring](#statistics--monitoring)
- [mTLS & Certificate Authentication](#mtls--certificate-authentication)
- [Configuration](#configuration)
- [Performance Considerations](#performance-considerations)
- [API Reference](#api-reference)

---

## Overview

Nitella's reverse proxy is a Layer 4 (TCP) proxy that operates at the transport layer. Unlike HTTP proxies, it forwards raw TCP streams without inspecting application-layer content, making it suitable for:

- SSH, RDP, VNC remote access
- Database connections (MySQL, PostgreSQL, MongoDB)
- Any TCP-based protocol
- HTTP/HTTPS (pass-through mode)

### Key Features

| Feature | Description |
|---------|-------------|
| **Dynamic Routing** | Route connections to different backends based on rules |
| **Rule Engine** | Match by IP, CIDR, GeoIP, TLS certificate attributes |
| **Mock Services** | Respond with fake SSH/RDP/HTTP banners (honeypot mode) |
| **Statistics** | Connection tracking, aggregation by IP/Country/ISP |
| **Rate Limiting** | Fail2Ban-style auto-escalation blocking |
| **mTLS** | Certificate-based client authentication |
| **Process Isolation** | Option to run listeners in separate OS processes |
| **FFI GeoIP** | Zero-copy GeoIP lookups via synurang FFI |

---

## Architecture

```
                                     ┌────────────────────────────────────────┐
                                     │          ProxyManager                  │
                                     │  (Coordinates all listeners & rules)   │
                                     └────────────────┬───────────────────────┘
                                                      │
           ┌──────────────────────────────────────────┼──────────────────────────────────────────┐
           │                                          │                                          │
           ▼                                          ▼                                          ▼
   ┌───────────────┐                          ┌───────────────┐                          ┌───────────────┐
   │ EmbeddedListener                         │ EmbeddedListener                         │ ProcessListener
   │ :8080 → Backend A                        │ :3389 → RDP Server                       │ :22 → SSH Farm
   │                                          │                                          │ (child process)
   │  ┌─────────────┐                         │  ┌─────────────┐                         └───────────────┘
   │  │ Rule Engine │                         │  │ Rule Engine │                                 │
   │  │ GeoIP Lookup│                         │  │ GeoIP Lookup│                          (Socketpair IPC)
   │  │ Stats       │                         │  │ Stats       │                                 │
   │  └─────────────┘                         │  └─────────────┘                                 ▼
   └───────────────┘                          └───────────────┘                          ┌───────────────┐
           │                                          │                                  │ Child Process │
           ▼                                          ▼                                  └───────────────┘
   ┌───────────────┐                          ┌───────────────┐
   │   Backend A   │                          │  RDP Server   │
   │ 192.168.1.10  │                          │ 192.168.1.20  │
   └───────────────┘                          └───────────────┘
```

### Components

| Component | Description |
|-----------|-------------|
| `ProxyManager` | Central coordinator for all listeners, rules, and shared services |
| `EmbeddedListener` | Listener running as a goroutine (lightweight, good for embedded) |
| `ProcessListener` | Listener running as a child OS process (isolated, better security) |
| `GeoIPService` | Shared GeoIP lookup with multi-layer caching |
| `StatsService` | Connection statistics collection and aggregation |

---

## Deployment Modes

### Embedded Mode (Default)

Listeners run as goroutines within the main process.

**Pros:**
- Low resource overhead
- Fast startup
- Suitable for embedded devices

**Cons:**
- Crash in one listener can affect others
- Shared memory space

```bash
nitellad --listen :8080 --backend 192.168.1.10:80
```

### Separated Process Mode

Each listener runs as a separate child OS process. Communication between the parent (manager) and child (listener) is handled via high-performance IPC.

**Mechanism:**
- **Linux/macOS**: Uses `socketpair()` for an anonymous, kernel-isolated bidirectional connection. The parent passes the connection to the child via an inherited file descriptor. No TLS is required as the channel is physically isolated by the kernel.
- **Windows**: Uses TCP over localhost with a randomized port.

**Pros:**
- **Fault Isolation**: A crash in one listener (e.g., segfault in a plugin) kills only that child process. The main manager and other listeners remain unaffected.
- **Security**: Listeners run in their own memory space.
- **Restartability**: Individual listeners can be restarted without dropping connections on other ports.

**Cons:**
- Higher memory footprint (multiple Go runtimes).

```bash
# Enable process mode with --process-mode flag
nitellad --listen :8080 --backend localhost:3000 --process-mode

# Child process is spawned automatically for each proxy
# Internal command (used by parent process):
# nitellad child --ipc-fd 3 --listen :8080 --id proxy1
```

---

## Listener Management

### Create a Listener

```go
resp, err := proxyManager.CreateProxy(&pb.CreateProxyRequest{
    Name:           "web-proxy",
    ListenAddr:     ":8080",
    DefaultBackend: "192.168.1.10:80",
    DefaultAction:  common.ActionType_ACTION_TYPE_ALLOW,
})
```

### Default Actions

| Action | Behavior |
|--------|----------|
| `ALLOW` | Forward to default backend (blacklist mode - block specific IPs) |
| `BLOCK` | Reject connection (whitelist mode - allow specific IPs) |
| `MOCK` | Respond with fake service banner |
| `REQUIRE_APPROVAL` | Hold connection and request real-time user approval (see [APPROVAL_SYSTEM.md](APPROVAL_SYSTEM.md)) |

### Multiple Listeners

A single `ProxyManager` can manage multiple listeners on different ports:

```yaml
entrypoints:
  web:
    address: ":8080"
    default_action: allow

  rdp:
    address: ":3389"
    default_action: block

  ssh-honeypot:
    address: ":22"
    default_action: mock
    default_mock: ssh-tarpit
```

---

## Rule Engine

Rules define how connections are handled based on conditions. Rules are evaluated in priority order (highest first).

### Quick Reference

| Condition Type | Example |
|----------------|---------|
| `source_ip` | `192.168.1.0/24`, `1.2.3.4` |
| `geo_country` | `KR`, `US`, `JP` |
| `geo_city` | `Seoul`, `Tokyo` |
| `geo_isp` | `Amazon`, `Google Cloud` |
| `tls_fingerprint` | `SHA256:abc123...` |
| `tls_cn` | `admin@company.com` |

### Actions

| Action | Description |
|--------|-------------|
| `ALLOW` | Forward to backend |
| `BLOCK` | Reject immediately |
| `MOCK` | Return fake service response |
| `REQUIRE_APPROVAL` | Hold connection pending user approval via CLI/mobile |

### Example Rule

```json
{
  "name": "Block Datacenter IPs",
  "priority": 100,
  "enabled": true,
  "conditions": [
    {"type": "geo_isp", "op": "contains", "value": "Amazon"},
    {"type": "geo_isp", "op": "contains", "value": "Google"}
  ],
  "action": "BLOCK"
}
```

---

## Mock Services

Mock services respond with fake protocol banners, useful for:
- Honeypots (detect attackers)
- Tarpits (slow down scanners)
- Testing without real backends

### Supported Presets

| Preset | Description |
|--------|-------------|
| `ssh` | OpenSSH banner, accepts auth (fails all) |
| `ssh-tarpit` | Extremely slow SSH auth (wastes attacker time) |
| `http` | Basic HTTP 200 response |
| `http-403` | HTTP 403 Forbidden |
| `http-404` | HTTP 404 Not Found |
| `rdp` | RDP negotiation banner |
| `mysql` | MySQL handshake |
| `redis` | Redis protocol |
| `telnet` | Telnet banner |
| `raw` | Echo back client data |

### Configuration

```yaml
entrypoints:
  honeypot:
    address: ":22"
    default_action: mock
    default_mock: ssh-tarpit
```

---

## GeoIP Integration

> **Full documentation: [GEOIP.md](GEOIP.md)**

Every connection triggers a GeoIP lookup to determine:
- Country / Country Code
- City / Region
- ISP / Organization
- ASN

### Lookup Strategy

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  L1 Cache   │────►│  L2 Cache   │────►│  Local DB   │────►│ Remote API  │
│  (in-memory)│     │  (SQLite)   │     │  (MaxMind)  │     │  (ip-api)   │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### FFI Mode (Zero-Copy)

Nitella uses synurang FFI for zero-copy GeoIP lookups when running in embedded mode:

```go
// Zero-copy GeoIP via synurang FFI
ffiServer := geoip.NewFfiServer(geoipManager)
ffiConn := geoip_pb.NewFfiClientConn(ffiServer)
geoIPClient := geoip.NewFfiClient(ffiConn)
```

### Configuration

```bash
nitellad \
  --geoip-city /path/to/GeoLite2-City.mmdb \
  --geoip-isp /path/to/GeoLite2-ASN.mmdb \
  --geoip-strategy "l1,l2,local,remote"
```

---

## Statistics & Monitoring

The proxy collects connection statistics for analysis and visualization.

### Data Collected

| Table | Contents | Retention |
|-------|----------|-----------|
| `connection_log` | Raw connection events (IP, bytes, duration, action) | 24 hours |
| `ip_stats` | Aggregated per-IP statistics | 30 days |
| `geo_stats` | Aggregated by country/city/ISP | 90 days |

### Statistics Features

- **Recency Weight**: IPs weighted by how recently they connected (exponential decay)
- **One-Click Rules**: Create block/allow rules directly from statistics
- **GeoIP Breakdown**: See connections by country, city, ISP
- **Sampling Mode**: Log only 1 in N connections for high-traffic scenarios

### API Examples

```protobuf
// Get top IPs by connection count
rpc GetIPStats(GetIPStatsRequest) returns (GetIPStatsResponse);

// Get statistics by country
rpc GetGeoStats(GetGeoStatsRequest) returns (GetGeoStatsResponse);

// Create a block rule from statistics
rpc CreateRuleFromStats(CreateRuleFromStatsRequest) returns (Rule);
```

### Configuration

```protobuf
// Enable statistics and configure retention
ConfigureStatsRequest {
  enabled: true
  raw_retention_hours: 24      // Keep raw logs for 24h
  stats_retention_days: 30     // Keep IP stats for 30 days
  geo_retention_days: 90       // Keep geo stats for 90 days
  sampling_rate: 1             // Log every connection (1) or sample (N)
}
```

---

## mTLS & Certificate Authentication

The proxy supports mutual TLS (mTLS) where both client and server present certificates.

### Certificate Conditions

| Condition | Description |
|-----------|-------------|
| `tls_cert_present` | Client presented a valid certificate |
| `tls_fingerprint` | SHA256 fingerprint of client cert |
| `tls_cn` | Certificate Common Name |
| `tls_serial` | Certificate serial number |

### Use Case: Personal Device Access

```yaml
rules:
  - name: "My Laptop"
    priority: 200
    conditions:
      - type: tls_fingerprint
        value: "SHA256:abc123def456..."
    action: allow
    backend: "192.168.1.1:22"  # Full SSH access

  - name: "Default"
    priority: 0
    action: block  # Block everyone else
```

### Configuration

```bash
nitellad \
  --tls-cert /path/to/server.crt \
  --tls-key /path/to/server.key \
  --tls-ca /path/to/ca.crt \
  --mtls
```

---

## Configuration

### YAML Config (Traefik-style)

```yaml
entrypoints:
  web:
    address: ":8443"
    default_action: block

tcp:
  routers:
    korea-only:
      entryPoints: ["web"]
      rule: "GeoCountry(`KR`)"
      service: backend-svc

  services:
    backend-svc:
      address: "192.168.1.100:80"
```

### Command Line

```bash
nitellad --listen :8080 --backend localhost:3000
nitellad --config proxy.yaml
nitellad --config proxy.yaml --geoip-city /path/to/GeoLite2-City.mmdb
```

---

## Performance Considerations

### Connection Handling

- Each connection is handled in a separate goroutine
- Bidirectional byte copy using `io.Copy` (efficient zero-copy when possible)
- GeoIP lookups are cached (L1 in-memory, L2 SQLite)
- FFI mode eliminates serialization overhead for GeoIP

### Statistics Performance

- **Non-blocking**: Stats recording uses buffered channel (10K capacity)
- **Batch writes**: Events are batched and written every second
- **WAL mode**: SQLite configured for concurrent reads

### Memory Usage

| Component | Memory |
|-----------|--------|
| Per-listener overhead | ~100 KB |
| Per-connection | ~10 KB |
| GeoIP L1 cache (1000 entries) | ~200 KB |
| Stats event buffer | ~1 MB |

---

## API Reference

### gRPC Services

| Service | Description |
|---------|-------------|
| `ProxyControlService` | Manage listeners and rules |
| `ProcessControl` | Child process IPC (internal) |

### Key RPCs

```protobuf
// Listener Management
rpc CreateProxy(CreateProxyRequest) returns (CreateProxyResponse);
rpc DisableProxy(DisableProxyRequest) returns (DisableProxyResponse);
rpc EnableProxy(EnableProxyRequest) returns (EnableProxyResponse);
rpc GetProxyStatus(GetProxyStatusRequest) returns (GetProxyStatusResponse);

// Rule Management
rpc AddRule(AddRuleRequest) returns (AddRuleResponse);
rpc RemoveRule(RemoveRuleRequest) returns (RemoveRuleResponse);
rpc ListRules(ListRulesRequest) returns (ListRulesResponse);

// Connection Management
rpc GetActiveConnections(GetActiveConnectionsRequest) returns (GetActiveConnectionsResponse);
rpc CloseConnection(CloseConnectionRequest) returns (CloseConnectionResponse);
rpc CloseAllConnections(CloseAllConnectionsRequest) returns (CloseAllConnectionsResponse);

// Statistics
rpc ConfigureStats(ConfigureStatsRequest) returns (ConfigureStatsResponse);
rpc GetIPStats(GetIPStatsRequest) returns (GetIPStatsResponse);
rpc GetGeoStats(GetGeoStatsRequest) returns (GetGeoStatsResponse);
rpc GetStatsSummary(Empty) returns (StatsSummaryResponse);
```

### Proto Files

| File | Contents |
|------|----------|
| `api/proxy/proxy.proto` | Proxy control, rules, events |
| `api/process/process.proto` | Child process IPC |
| `api/geoip/geoip.proto` | GeoIP microservice |
| `api/common/common.proto` | Shared types |

---

## Related Documentation

- [GEOIP.md](GEOIP.md) - GeoIP service architecture and configuration
- [APPROVAL_SYSTEM.md](APPROVAL_SYSTEM.md) - Real-time connection approval workflow
- [HUB.md](HUB.md) - Hub architecture for remote management