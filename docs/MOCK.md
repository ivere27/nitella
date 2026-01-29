# Mock Server

A honeypot/mock server that emulates various network protocols to detect and waste attacker resources.

## Overview

The mock server responds to connections with realistic protocol banners and responses, making it useful for:

- **Honeypots**: Detect scanning and attack attempts
- **Tarpits**: Waste attacker/bot time with slow responses
- **Testing**: Simulate services for integration testing

## Supported Protocols

| Protocol | Port (typical) | Description |
|----------|----------------|-------------|
| `http`   | 80, 8080       | HTTP server with configurable status codes |
| `ssh`    | 22             | SSH banner (OpenSSH style) |
| `mysql`  | 3306           | MySQL handshake + access denied |
| `mssql`  | 1433           | TDS pre-login response |
| `redis`  | 6379           | RESP protocol with NOAUTH |
| `smtp`   | 25, 587        | ESMTP with capabilities |
| `telnet` | 23             | Telnet negotiation + login prompt |
| `rdp`    | 3389           | X.224 Connection Confirm |
| `raw`    | any            | Custom payload or "Access Denied" |

## Running the Server

### Command Line Flags

```
-port int        Port to listen on (default 8080)
-protocol string Protocol to emulate: http, ssh, mysql, mssql, rdp, telnet, redis, smtp (default "http")
-delay int       Delay in milliseconds before sending response (default 0)
-payload string  Custom payload to send (overrides protocol default)
-tarpit          Enable tarpit mode - waste attacker time with slow/endless responses
-drip int        Drip interval in ms (send bytes one at a time with this delay)
-max-conns int   Maximum concurrent connections (default 128)
```

### Resource Limits

The server limits concurrent connections to prevent resource exhaustion attacks. Default is 128 connections, which uses approximately 1MB of memory for goroutine stacks.

For high-traffic honeypots, increase the limit:
```bash
./mock -port 22 -protocol ssh -tarpit -max-conns 512
```

Connections beyond the limit are immediately rejected.

### Example Usage

**Basic HTTP mock:**
```bash
./mock -port 8080 -protocol http
```

**SSH honeypot:**
```bash
./mock -port 2222 -protocol ssh
```

**MySQL with delay:**
```bash
./mock -port 3306 -protocol mysql -delay 500
```

**Tarpit mode (wastes attacker time):**
```bash
./mock -port 22 -protocol ssh -tarpit
```

**Drip mode (slow byte-by-byte):**
```bash
./mock -port 8080 -protocol http -drip 100
```

## Tarpit Mode

Tarpit mode is designed to waste attacker resources by keeping connections open as long as possible.

### How It Works

When `-tarpit` is enabled:
- Random delays are added between responses
- Data is sent byte-by-byte (drip mode) with 1 second default interval
- Protocol-specific behaviors engage to maximize connection time

### Protocol-Specific Tarpit Behavior

| Protocol | Tarpit Behavior |
|----------|-----------------|
| SSH      | Endless random pre-banner lines (endlessh style) |
| MySQL    | Infinite authentication loop with rotating error messages |
| Redis    | PING works, AUTH always fails with different errors, QUIT ignored |
| SMTP     | Accepts entire mail flow but never delivers |
| HTTP     | Slowloris-style slow drip of large fake page |
| Telnet   | Endless login prompts |

### Drip Mode

Drip mode sends data byte-by-byte with configurable delays:

```
Normal:  "SSH-2.0-OpenSSH_8.9\r\n"  -> sent instantly
Drip:    "S" [100ms] "S" [100ms] "H" [100ms] ...  -> sent slowly
```

This ties up scanner connections waiting for complete banners.

**Enable drip mode:**
```bash
# With tarpit (1 second per byte default)
./mock -protocol ssh -tarpit

# Custom interval (100ms per byte)
./mock -protocol ssh -drip 100
```

## Makefile Targets

```bash
# Build
make mock_build

# Run (default: HTTP on port 8080)
make mock_run

# Run with options
make mock_run PORT=2222 PROTOCOL=ssh

# Run tests
make mock_test                # Unit tests
make mock_test_integration    # Integration tests

# Docker
make mock_docker_build
make mock_docker_run PORT=2222 PROTOCOL=ssh
```

## Docker

```bash
# Build
make mock_docker_build

# Run HTTP mock
make mock_docker_run

# Run SSH tarpit
make mock_docker_run PORT=22 PROTOCOL=ssh

# Manual docker run
docker run -it --rm \
  -p 2222:2222 \
  -e PORT=2222 \
  -e PROTOCOL=ssh \
  nitella-mock
```

## Library Usage

```go
import "github.com/ivere27/nitella/pkg/mockproto"

// Handle a connection with config
config := mockproto.MockConfig{
    Protocol:       "ssh",
    DelayMs:        100,
    Tarpit:         false,
    DripIntervalMs: 0,
}

err := mockproto.HandleConnection(conn, config)
```

### MockConfig Options

| Field          | Type     | Description |
|----------------|----------|-------------|
| `Protocol`     | string   | Protocol to emulate |
| `StatusCode`   | int      | HTTP status code (http only) |
| `DelayMs`      | int      | Fixed delay before response |
| `Payload`      | []byte   | Custom payload (overrides default) |
| `RandomDelay`  | bool     | Add random delays (auto-enabled with tarpit) |
| `DripBanner`   | bool     | Send byte-by-byte (auto-enabled with tarpit or drip flag) |
| `DripIntervalMs` | int    | Milliseconds between bytes in drip mode |
| `Tarpit`       | bool     | Enable tarpit mode |
| `NeverComplete` | bool    | Hold connection open indefinitely (raw protocol) |

### Individual Protocol Handlers

```go
// Direct protocol calls
mockproto.MockHTTP(conn, config)
mockproto.MockSSH(conn, config)
mockproto.MockMySQL(conn, config)
mockproto.MockMSSQL(conn)
mockproto.MockRDP(conn)
mockproto.MockRedis(conn, config)
mockproto.MockSMTP(conn, config)
mockproto.MockTelnet(conn, config)
```

### Utility Functions

```go
// Send data byte-by-byte with delays
mockproto.DripWrite(conn, data, intervalMs)

// Hold connection open (reads until client disconnects)
mockproto.HoldOpen(conn)

// Random delay between min and max milliseconds
mockproto.RandomDelay(minMs, maxMs)
```

## Testing

**Unit tests:**
```bash
make mock_test
```

**Integration tests:**
```bash
make mock_test_integration
```

## Use Cases

### Honeypot Deployment

Deploy on common ports to detect scanning:

```bash
# SSH honeypot
./mock -port 22 -protocol ssh -tarpit &

# MySQL honeypot
./mock -port 3306 -protocol mysql -tarpit &

# Redis honeypot
./mock -port 6379 -protocol redis -tarpit &
```

### Scanner Slowdown

Use tarpit mode to waste bot resources:

```bash
# Endlessh-style SSH tarpit
./mock -port 22 -protocol ssh -tarpit

# This sends endless random lines before the SSH banner,
# keeping scanners connected for hours
```

### Integration Testing

Mock services for testing:

```go
// Start mock server
listener, _ := net.Listen("tcp", ":0")
go func() {
    conn, _ := listener.Accept()
    mockproto.MockMySQL(conn, mockproto.MockConfig{})
}()

// Test your MySQL client against it
client.Connect(listener.Addr().String())
```
