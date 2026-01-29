# GeoIP Service

This service provides geographical information lookups for IP addresses, utilizing a multi-layered fallback strategy.

## Architecture

The GeoIP service is designed with a fallback mechanism to ensure high availability and performance.

### Lookup Strategy

The default strategy is:
1. **L1 Cache**: In-memory LRU cache (configurable capacity, default 10000 entries)
2. **L2 Cache**: SQLite persistent cache (configurable TTL, default 24 hours, 0 = permanent)
3. **Local DB**: Local MaxMind GeoIP2/GeoLite2 City and ASN databases
4. **Remote Provider**: HTTP lookups to external providers (e.g., ipwhois.app, ip-api.com) with automatic failover

This order is configurable via the `--config` flag or programmatically.

### Protocol

The service exposes two gRPC services:

- **GeoIPService** (port 50052): Public lookup service
- **GeoIPAdminService** (port 50053): Admin operations (requires token)

## Running the Server

### Command Line Flags

```
-port int          Public gRPC server port (default 50052)
-admin-port int    Admin gRPC server port (default 50053, 0 to disable)
-admin-token str   Admin authentication token (env: GEOIP_TOKEN, auto-generated if empty)
-db string         L2 cache SQLite path (default "./geoip_cache.db")
-db-ttl int        L2 cache TTL in hours, 0 = permanent (default 24)
-city-db string    Path to MaxMind City DB (.mmdb)
-isp-db string     Path to MaxMind ISP/ASN DB (.mmdb)
-remote string     Remote providers (comma-separated name=url pairs, no default)
-config string     Path to YAML config file
```

### Environment Variables

| Variable | Description |
|----------|-------------|
| `GEOIP_TOKEN` | Admin authentication token (alternative to `--admin-token` flag) |
| `NITELLA_TRACE` | Set to `1` to enable trace-level logging |

### Example Usage

**Basic Run (No Remote Providers):**
```bash
./geoip-server
```

**With Remote Provider:**
```bash
./geoip-server --remote "ipwhois=http://ipwhois.app/json/%s"
```

**With Local MaxMind Database:**
```bash
./geoip-server \
  --city-db /path/to/GeoLite2-City.mmdb \
  --isp-db /path/to/GeoLite2-ASN.mmdb
```

**With Config File:**
```bash
./geoip-server --config geoip_provider.yaml
```

### Startup Logging

On startup, the server logs its configuration:
```
2026/01/29 10:25:58 Loaded configuration from geoip_provider.yaml
2026/01/29 10:25:58   L1 Cache: capacity=10000
2026/01/29 10:25:58   L2 Cache: ./geoip_cache.db (TTL: 24h)
2026/01/29 10:25:58   Local DB: not loaded
2026/01/29 10:25:58   Providers: ipwhois
2026/01/29 10:25:58   Strategy: [l1 l2 local remote]
```

## Configuration File

Example `geoip_provider.yaml`:

```yaml
geoip:
  strategy: ["l1", "l2", "local", "remote"]
  timeout_ms: 3000

  cache:
    l1:
      capacity: 10000
    l2:
      enabled: true
      path: "./geoip_cache.db"
      ttl_hours: 24  # 0 = permanent

  local:
    enabled: false
    city_db: "/path/to/GeoLite2-City.mmdb"
    isp_db: "/path/to/GeoLite2-ASN.mmdb"

  remote_providers:
    - name: ipwhois
      enabled: true
      url: "http://ipwhois.app/json/%s"
      priority: 1

    - name: ip-api
      enabled: false
      url: "http://ip-api.com/json/%s"
      priority: 2
      field_mapping:
        country: ["country"]
        country_code: ["countryCode"]
        region: ["region"]
        region_name: ["regionName"]
        city: ["city"]
        zip: ["zip"]
        latitude: ["lat"]
        longitude: ["lon"]
        timezone: ["timezone"]
        isp: ["isp"]
        org: ["org"]
        as: ["as"]

  admin:
    port: 50053
    token: "your-secret-token"
```

## Admin CLI

The CLI tool connects to the admin service and requires authentication.

### Command Line Flags

```
--addr string    Admin server address (default "localhost:50053")
--token string   Admin authentication token (env: GEOIP_TOKEN)
```

### Usage

**Single Command:**
```bash
./geoip --addr localhost:50053 --token YOUR_TOKEN status
./geoip --addr localhost:50053 --token YOUR_TOKEN lookup 8.8.8.8
```

**Interactive Mode:**
```bash
./geoip --addr localhost:50053 --token YOUR_TOKEN
geoip> status
geoip> lookup 8.8.8.8
geoip> provider list
geoip> help
geoip> exit
```

### Available Commands

```
lookup <ip>                    - Lookup IP geolocation
status                         - Show server status

provider list                  - List all providers
provider add <name> <url>      - Add HTTP provider
provider remove <name>         - Remove provider
provider enable <name>         - Enable provider
provider disable <name>        - Disable provider
provider stats [name]          - Show provider statistics
provider order <n1> <n2> ...   - Reorder providers

localdb load <city> [isp]      - Load MaxMind databases
localdb unload                 - Unload local databases
localdb status                 - Show local DB status

cache stats                    - Show cache statistics
cache clear [l1|l2|all]        - Clear cache layers
cache settings                 - Show cache settings

strategy show                  - Show current strategy
strategy set <l1,l2,local,...> - Set lookup order

config reload                  - Reload configuration
config save                    - Save configuration

help                           - Show this help
exit                           - Exit shell
```

## Makefile Targets

```bash
# Build server and CLI
make geoip_build

# Run server (auto-detects geoip_provider.yaml if exists)
make geoip_run_local

# Run server with MaxMind databases
make geoip_run_local CITY_DB=/path/to/city.mmdb ISP_DB=/path/to/isp.mmdb

# Run server with specific config file
make geoip_run_config CONFIG=my_config.yaml

# Run CLI
make geoip_run_cli TOKEN=your-admin-token

# Run tests
make geoip_test
make geoip_test_integration
```

## Admin API (gRPC)

The admin service (port 50053 by default) provides runtime management:

### Lookup (Authenticated)
- `Lookup` - IP geolocation lookup
- `GetStatus` - Service health and status

### Provider Management
- `ListProviders` - List all configured providers with stats
- `AddProvider` - Add a new HTTP provider
- `RemoveProvider` - Remove a provider
- `EnableProvider` / `DisableProvider` - Toggle provider
- `ReorderProviders` - Change provider priority
- `GetProviderStats` - Get detailed provider statistics

### Cache Management
- `GetCacheStats` - Get L1/L2 cache statistics
- `ClearCache` - Clear L1, L2, or both caches (also resets hit/miss stats)
- `UpdateCacheSettings` - Update cache configuration
- `VacuumL2` - Optimize L2 SQLite database

### Local Database
- `LoadLocalDB` - Load MaxMind databases at runtime
- `UnloadLocalDB` - Unload local databases
- `GetLocalDBStatus` - Check local DB status

### Strategy
- `GetStrategy` - Get current lookup strategy
- `SetStrategy` - Change lookup order

### Config
- `ReloadConfig` - Reload from config file
- `SaveConfig` - Save current config to file

## Library Usage

```go
import "github.com/ivere27/nitella/pkg/geoip"

// Create manager
manager := geoip.NewManager()

// Setup L2 cache (24 hour TTL)
manager.InitL2("./cache.db", 24)

// Setup local MaxMind database
manager.SetLocalDB("/path/to/city.mmdb", "/path/to/isp.mmdb")

// Add remote provider
manager.AddRemoteProvider("ipwhois", "http://ipwhois.app/json/%s")

// Create client
client := geoip.NewEmbeddedClient(manager)

// Lookup
ctx := context.Background()
info, err := client.Lookup(ctx, "8.8.8.8")
if err != nil {
    log.Fatal(err)
}
fmt.Printf("Country: %s, City: %s, ISP: %s\n", info.Country, info.City, info.Isp)
fmt.Printf("Source: %s, Latency: %dms\n", info.Source, info.LatencyMs)

// Cleanup
manager.Close()
```

### Remote Client

```go
// Connect to remote GeoIP server (public service)
client, err := geoip.NewRemoteClient("localhost:50052")
if err != nil {
    log.Fatal(err)
}
defer client.Close()

info, err := client.Lookup(ctx, "1.1.1.1")
```

## Testing

**Run Unit Tests:**
```bash
make geoip_test
```

**Run Integration Tests:**
```bash
make geoip_test_integration
```

## MaxMind Database

Download GeoLite2 databases from [MaxMind](https://dev.maxmind.com/geoip/geolite2-free-geolocation-data):

- GeoLite2-City.mmdb - City-level geolocation
- GeoLite2-ASN.mmdb - ISP/ASN information

Place them in a known location and reference via `--city-db` and `--isp-db` flags.

## Cache Behavior

### L1 Cache (In-Memory)
- LRU eviction policy
- Configurable capacity (default 10000)
- Fastest lookup, no persistence
- `cache clear l1` resets hit/miss counters

### L2 Cache (SQLite)
- Persistent across restarts
- Configurable TTL (default 24 hours, 0 = never expire)
- Automatic cleanup of expired entries
- `VacuumL2` API for database optimization
- `cache clear l2` resets hit/miss counters

### Cache Population
When a lookup succeeds from local DB or remote provider, the result is automatically cached in both L1 and L2.

## Recommended Providers

| Provider | URL Format | Rate Limit | Notes |
|----------|-----------|------------|-------|
| ipwhois.app | `http://ipwhois.app/json/%s` | 10k/month free | Recommended for low volume |
| ip-api.com | `http://ip-api.com/json/%s` | 45/minute | Free tier rate limited |
| ipinfo.io | `https://ipinfo.io/%s/json` | 50k/month free | Requires API key for higher limits |

## Docker

The Docker image includes GeoLite2 databases by default.

```bash
# Build and run with admin token
make geoip_docker_run GEOIP_TOKEN=your-secret-token

# With config file
make geoip_docker_run GEOIP_TOKEN=your-secret-token GEOIP_CONFIG=geoip_provider.yaml

# Manual docker run
docker run -it --rm \
  -p 50052:50052 -p 50053:50053 \
  -e GEOIP_TOKEN=your-secret-token \
  -v ./data:/app/data \
  nitella-geoip
```

If `GEOIP_TOKEN` is not provided, a random token will be generated and logged at startup.

## Attribution

This product includes GeoLite2 data created by MaxMind, available from [https://www.maxmind.com](https://www.maxmind.com).

GeoLite2 databases are licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) - free for commercial use with attribution.
