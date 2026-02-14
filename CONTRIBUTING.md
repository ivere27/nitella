# Contributing to Nitella

Thank you for your interest in contributing to Nitella! This document provides guidelines and information for contributors.

## Contributor License Agreement (CLA)

By submitting a pull request or patch to this repository, you agree to the following terms:

1. **License Grant**: You license your contribution under the Apache License 2.0, consistent with the project's LICENSE file.

2. **Original Work**: You represent that your contribution is your original work, or you have the necessary rights to submit it under these terms.

3. **No Warranty**: You provide your contribution "as is" without any warranty.

## How to Contribute

### Reporting Issues

- Check existing issues before creating a new one
- Include relevant details: OS, Go version, steps to reproduce
- Provide error messages and logs if applicable

### Submitting Code

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Ensure tests pass (`make test`)
5. Commit with clear messages
6. Push to your fork
7. Open a pull request

### Code Style

- **Go**: Follow standard Go conventions, run `gofmt`
- **Proto**: Follow Google's protobuf style guide

### Commit Messages

Use clear, descriptive commit messages:

```
component: short description

Longer explanation if needed. Explain what and why,
not how (the code shows how).
```

Examples:
- `geoip: add support for ipinfo.io provider`
- `cache: fix L2 cache TTL expiration`
- `provider: improve error handling for timeouts`

### Pull Request Guidelines

- Keep PRs focused on a single change
- Update documentation if needed
- Add tests for new functionality
- Ensure CI passes before requesting review

## Development Setup

```bash
# Clone the repository
git clone https://github.com/ivere27/nitella.git
cd nitella

# Install dependencies
make deps

# Generate protobuf files
make proto

# Build
make build

# Run tests
make test
```

## Project Structure

```
nitella/
├── api/           # Protobuf definitions (common, proxy, hub, local, geoip, process)
├── app/           # Flutter mobile app
├── cmd/           # Command binaries (nitellad, nitella, hub, geoip, mock)
├── docs/          # Documentation
├── pkg/
│   ├── api/       # Generated protobuf code
│   ├── node/      # Proxy engine (listener, rules, stats)
│   ├── server/    # gRPC server implementations
│   ├── service/   # Mobile backend logic
│   ├── hub/       # Hub server implementation
│   ├── identity/  # BIP-39 identity management
│   ├── pairing/   # PAKE and QR code pairing
│   ├── p2p/       # WebRTC P2P connections
│   ├── crypto/    # E2E encryption
│   ├── geoip/     # GeoIP library
│   ├── mockproto/ # Mock protocol handlers
│   └── ...
└── test/
    └── integration/ # Integration tests
```

## Testing

- Write unit tests for new functionality
- Use table-driven tests where appropriate
- Mock external dependencies (HTTP providers, databases)

```bash
# Run all tests
make test

# Run tests with verbose output
go test -v ./...

# Run specific test
go test -v ./pkg/geoip/... -run TestManager_CacheHit
```

## Questions?

- Open a GitHub Issue for bugs or feature requests
- Open a GitHub Discussion for general questions

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.
