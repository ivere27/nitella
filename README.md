# Nitella

A collection of modular network services and libraries.

## Modules

### GeoIP

High-performance GeoIP lookup service with multi-layer caching and multiple provider support.

- **Multi-layer Caching**: L1 (in-memory LRU) + L2 (SQLite persistent)
- **Multiple Data Sources**: Local MaxMind databases, remote HTTP providers with automatic failover
- **Configurable Strategy**: Define lookup order, hot-reload configuration
- **gRPC API**: Public lookup service + Admin management service

See [docs/GEOIP.md](docs/GEOIP.md) for detailed documentation.

### Mock Server

Honeypot/mock server that emulates various network protocols to detect scanning and waste attacker resources.

- **Multiple Protocols**: HTTP, SSH, MySQL, MSSQL, Redis, SMTP, Telnet, RDP
- **Tarpit Mode**: Waste attacker time with slow/endless responses
- **Drip Mode**: Send data byte-by-byte to tie up scanners
- **Customizable**: Custom payloads, delays, and behaviors

See [docs/MOCK.md](docs/MOCK.md) for detailed documentation.

## Quick Start

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

## Project Structure

```
nitella/
├── api/                      # Protobuf definitions
│   ├── common/               # Shared types
│   └── geoip/                # GeoIP service
├── cmd/
│   ├── geoip-server/         # GeoIP server binary
│   ├── geoip/                # GeoIP CLI binary
│   └── mock/                 # Mock server binary
├── pkg/
│   ├── api/                  # Generated protobuf code
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

# Format code
make fmt

# Clean build artifacts
make clean
```

### Module-specific commands

```bash
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
```

## Third-Party Data

This project uses GeoLite2 data created by MaxMind, available from [https://www.maxmind.com](https://www.maxmind.com).

The GeoLite2 databases are licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and are free for commercial use with attribution.

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.
