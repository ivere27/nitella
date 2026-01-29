# Nitella

A collection of modular network services and libraries for security-focused infrastructure.

## Modules

### Nitellad - TCP Reverse Proxy

A security-first Layer 4 (TCP) reverse proxy with intelligent traffic routing, statistics, and mock services.

- **Rule Engine**: Match by IP, CIDR, GeoIP (country/city/ISP), TLS certificate attributes
- **Mock Services**: Honeypot mode with SSH/RDP/HTTP/MySQL tarpits
- **Statistics**: Connection tracking, aggregation by IP/Country/ISP
- **Rate Limiting**: Fail2Ban-style auto-escalation blocking
- **mTLS**: Certificate-based client authentication
- **Process Isolation**: Option to run listeners in separate OS processes
- **FFI GeoIP**: Zero-copy GeoIP lookups via synurang FFI

See [docs/REVERSE_PROXY.md](docs/REVERSE_PROXY.md) for detailed documentation.

### GeoIP

High-performance GeoIP lookup service with multi-layer caching and multiple provider support.

- **Multi-layer Caching**: L1 (in-memory LRU) + L2 (SQLite persistent)
- **Multiple Data Sources**: Local MaxMind databases, remote HTTP providers with automatic failover
- **Configurable Strategy**: Define lookup order, hot-reload configuration
- **gRPC API**: Public lookup service + Admin management service
- **FFI Support**: Zero-copy Go-to-Go FFI via synurang

See [docs/GEOIP.md](docs/GEOIP.md) for detailed documentation.

### Mock Server

Honeypot/mock server that emulates various network protocols to detect scanning and waste attacker resources.

- **Multiple Protocols**: HTTP, SSH, MySQL, MSSQL, Redis, SMTP, Telnet, RDP
- **Tarpit Mode**: Waste attacker time with slow/endless responses
- **Drip Mode**: Send data byte-by-byte to tie up scanners
- **Customizable**: Custom payloads, delays, and behaviors

See [docs/MOCK.md](docs/MOCK.md) for detailed documentation.

## Quick Start

### Nitellad (Reverse Proxy)

```bash
# Build
make nitellad_build nitella_build

# Run with backend
./bin/nitellad --listen :8080 --backend localhost:3000

# Run with config file
./bin/nitellad --config proxy.yaml

# Run with Admin API (generates random token if not provided)
./bin/nitellad --listen :8080 --backend localhost:3000 --admin-port 50051

# Run with specific admin token
./bin/nitellad --listen :8080 --backend localhost:3000 \
  --admin-port 50051 --admin-token your-secret-token

# Run in process mode (each proxy as separate child process)
./bin/nitellad --listen :8080 --backend localhost:3000 --process-mode

# Run with GeoIP
./bin/nitellad --config proxy.yaml --geoip-city /path/to/GeoLite2-City.mmdb

# With mTLS
./bin/nitellad --listen :8443 --backend localhost:3000 \
  --tls-cert server.crt --tls-key server.key --tls-ca ca.crt --mtls
```

### Nitella CLI

Connect to nitellad's admin API to manage proxies, rules, and connections.

```bash
# Build CLI
make nitella_build

# Connect to admin API (use token from daemon logs)
./bin/nitella --addr localhost:50051 --token your-admin-token

# Interactive shell
nitella> help
nitella> status
nitella> list

# Single command mode
./bin/nitella --addr localhost:50051 --token your-token status
./bin/nitella --addr localhost:50051 --token your-token lookup 8.8.8.8
```

**CLI Commands:**
- `status [proxy_id]` - Show proxy status
- `list` - List all proxies
- `proxy create <addr> <backend>` - Create a new proxy
- `proxy delete <proxy_id>` - Delete a proxy
- `rule list <proxy_id>` - List rules for a proxy
- `rule add <proxy_id> <allow|block> <ip>` - Add a rule
- `rule remove <proxy_id> <rule_id>` - Remove a rule
- `conn [proxy_id]` - List active connections (all proxies if no id)
- `conn close <proxy_id> <conn_id>` - Close a connection
- `conn closeall [proxy_id]` - Close all connections (all proxies if no id)
- `block <ip>` - Quick block an IP (all proxies)
- `allow <ip>` - Quick allow an IP (all proxies)
- `metrics` - Stream real-time metrics (Ctrl+C to stop)
- `geoip status` - Show GeoIP service status
- `geoip config local <city_db> [isp_db]` - Configure local MaxMind DB
- `geoip config remote <provider>` - Configure remote API provider
- `lookup <ip>` - GeoIP lookup for an IP
- `stream` - Stream connection events (Ctrl+C to stop)

**Keyboard Shortcuts:**
- `Tab` - Auto-complete commands
- `Up/Down` - Navigate command history
- `Ctrl+A/E` - Go to start/end of line
- `Ctrl+W` - Delete word backward
- `Alt+Backspace` - Delete word backward
- `Ctrl+Left/Right` - Jump to previous/next word
- `Alt+Left/Right` - Jump to previous/next word
- `Ctrl+L` - Clear screen
- `Ctrl+C` - Cancel current command (double-press to exit)

### GeoIP

```bash
# Build
make geoip_build

# Run server (auto-detects geoip_provider.yaml)
make geoip_run_local

# Run CLI
make geoip_run_cli TOKEN=your-admin-token

# Docker (includes GeoLite2 databases)
make geoip_docker_run GEOIP_TOKEN=your-secret-token
```

### Mock

```bash
# Build
make mock_build

# Run SSH honeypot
make mock_run PORT=2222 PROTOCOL=ssh

# Run with tarpit mode (wastes attacker time)
./bin/mock -port 22 -protocol ssh -tarpit

# Docker
make mock_docker_run PORT=2222 PROTOCOL=ssh
```

## Installation

```bash
git clone https://github.com/ivere27/nitella.git
cd nitella
make build
```

### Requirements

- Go 1.22+
- protoc (Protocol Buffers compiler)
- protoc-gen-go, protoc-gen-go-grpc

### Build synurang FFI plugin (optional)

For FFI GeoIP support:

```bash
make build_plugin
```

## Project Structure

```
nitella/
├── api/                      # Protobuf definitions
│   ├── common/               # Shared types (ActionType, ConditionType, etc.)
│   ├── proxy/                # Proxy control service
│   ├── process/              # Child process IPC
│   └── geoip/                # GeoIP service
├── cmd/
│   ├── nitellad/             # Reverse proxy daemon
│   ├── nitella/              # Proxy admin CLI
│   ├── geoip-server/         # GeoIP server binary
│   ├── geoip/                # GeoIP CLI binary
│   └── mock/                 # Mock server binary
├── pkg/
│   ├── api/                  # Generated protobuf code
│   ├── node/                 # Proxy engine (listener, rules, stats)
│   ├── server/               # gRPC server implementations
│   ├── config/               # YAML config loader
│   ├── geoip/                # GeoIP library
│   ├── mockproto/            # Mock protocol handlers
│   ├── shell/                # CLI utilities
│   └── log/                  # Logging utility
├── test/
│   └── integration/          # Integration tests
├── docs/                     # Documentation
├── go.mod
├── Makefile
└── README.md
```

## Development

```bash
# Build all modules
make build

# Run all tests
make test

# Generate protobuf files
make proto

# Format code
make fmt

# Clean build artifacts
make clean
```

### Module-specific commands

```bash
# Nitellad (Reverse Proxy)
make nitellad_build           # Build daemon
make nitella_build            # Build CLI
make nitellad_run             # Run daemon
make nitella_run TOKEN=xxx    # Run CLI
make nitellad_test            # Run unit tests
make nitellad_test_integration # Run integration tests

# GeoIP
make geoip_build              # Build server + CLI
make geoip_test               # Run unit tests
make geoip_test_integration   # Run integration tests
make geoip_run_local          # Run server locally
make geoip_run_cli TOKEN=xxx  # Run admin CLI
make geoip_docker_run         # Run in Docker

# Mock
make mock_build               # Build mock server
make mock_test                # Run unit tests
make mock_test_integration    # Run integration tests
make mock_run                 # Run (default: HTTP on 8080)
make mock_run PORT=22 PROTOCOL=ssh  # Run SSH mock
make mock_docker_run          # Run in Docker

# Plugin
make build_plugin             # Build synurang FFI plugin
```

## Configuration Example

```yaml
# proxy.yaml
entrypoints:
  web:
    address: ":8443"
    default_action: allow

  honeypot:
    address: ":22"
    default_action: mock
    default_mock: ssh-tarpit

tcp:
  routers:
    web-router:
      entryPoints: ["web"]
      service: backend-svc

  services:
    backend-svc:
      address: "192.168.1.100:80"
```

## Docker

### Quick Start

```bash
# Build and run nitellad with backend on host
make nitellad_docker_run BACKEND=host.docker.internal:3000

# With custom ports
make nitellad_docker_run BACKEND=host.docker.internal:3000 PROXY_PORT=9090

# GeoIP server
make geoip_docker_run GEOIP_TOKEN=your-secret-token

# Mock server
make mock_docker_run PORT=2222 PROTOCOL=ssh
```

### Known Issue: Firewall Blocking Docker Traffic

When using `host.docker.internal` to reach services on the host, firewalls like ufw may block traffic from the Docker network.

**Symptom:** Proxy starts but connections timeout when reaching the backend.

```
Failed to dial backend host.docker.internal:18000: dial tcp 172.17.0.1:18000: i/o timeout
```

**Solution:** Allow traffic from Docker's bridge network:

```bash
sudo ufw allow from 172.17.0.0/16
```

This rule persists across reboots.

## Third-Party Data

This project uses GeoLite2 data created by MaxMind, available from [https://www.maxmind.com](https://www.maxmind.com).

The GeoLite2 databases are licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and are free for commercial use with attribution.

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.
