# nitellad-rs

`nitellad-rs` is the Rust implementation of the Nitella proxy daemon.

The main, production-oriented daemon in this repository is the Go implementation
at `cmd/nitellad`. The Rust implementation is kept as an experimental and
benchmark-focused port of the same daemon behavior. It is useful for checking
how the proxy data path, process mode, admin API compatibility, persistence, and
resource usage compare against the Go daemon.

## Why The Benchmark Is Here

The `bench/` directory is placed under `nitellad-rs/` because the Rust port was
created mainly to compare daemon implementations.

The benchmark suite builds and runs both implementations:

- Go: `cmd/nitellad`
- Rust: `nitellad-rs`

It then drives both with the same local Rust HTTP backend and the same `wrk`
load profile. This makes `nitellad-rs/bench/` a cross-implementation benchmark
harness, not a Rust-only benchmark.

The benchmark is intended to compare:

- standard mode vs process mode
- throughput
- latency distribution
- memory use
- long-running stability and leak behavior

## Build

From the repository root:

```bash
cargo build --release --manifest-path nitellad-rs/Cargo.toml
```

The release binary is written to:

```text
nitellad-rs/target/release/nitellad-rs
```

For comparison, build the Go daemon with:

```bash
make nitellad_build
```

The Go binary is written to:

```text
bin/nitellad
```

## Run

Basic proxy mode:

```bash
nitellad-rs/target/release/nitellad-rs \
  --listen :8080 \
  --backend localhost:3000
```

With admin API:

```bash
nitellad-rs/target/release/nitellad-rs \
  --listen :8080 \
  --backend localhost:3000 \
  --admin-port 50051
```

Process mode:

```bash
nitellad-rs/target/release/nitellad-rs \
  --listen :8080 \
  --backend localhost:3000 \
  --process-mode
```

Show all supported flags:

```bash
nitellad-rs/target/release/nitellad-rs --help
```

### Linux Raw TCP Data Path

On Linux, the Rust daemon uses `splice(2)` by default for raw TCP-to-TCP
connections. Accepted raw TCP sockets are handed to a sharded non-Tokio
`epoll(7)`/`splice(2)` reactor, so Tokio stays out of the per-chunk data plane
and Rust does not create one splice worker thread per connection.

For non-Linux raw TCP and wrapped fallback copies, the userspace copy path uses
a fixed 32KB buffer, matching the Go daemon's userspace copy buffer.

## Benchmark

Prerequisites:

- Go
- Rust/Cargo
- `wrk`
- `curl`

Run the benchmark harness from the repository root:

```bash
bash nitellad-rs/bench/benchmark.sh
```

By default the harness runs the existing small-response request benchmark. It
can also run bulk and finite stream traffic in the same Go/Rust matrix:

```bash
BENCH_SCENARIOS=small_req,large_1m,stream_1m bash nitellad-rs/bench/benchmark.sh
```

The built-in scenarios are:

- `small_req`: 18-byte keep-alive HTTP response, for request-rate and latency.
- `large_1m`: 1MiB fixed-length response, for bulk transfer throughput.
- `stream_1m`: 128 chunked 8KiB writes, for finite streaming traffic.

Traffic scenario tunables:

- `LARGE_BYTES`: fixed response size for `large_1m` (default: `1048576`).
- `STREAM_CHUNKS`: chunk count for `stream_1m` (default: `128`).
- `STREAM_CHUNK_SIZE`: bytes per stream chunk (default: `8192`).
- `STREAM_DELAY_MS`: optional delay between stream chunks (default: `0`).

The harness writes results under:

```text
nitellad-rs/bench/results/
```

### Syscall Shape Profiling

For data-path investigation, `bench/profile_syscalls.sh` runs only the Rust
daemon under `strace -f -c`. This is not a throughput benchmark because strace
changes latency and throughput; use it to compare syscall counts before making
reactor changes.

Examples:

```bash
PROFILE_SCENARIO=small_req ./nitellad-rs/bench/profile_syscalls.sh
PROFILE_SCENARIO=large_1m ./nitellad-rs/bench/profile_syscalls.sh
PROFILE_SCENARIO=stream_1m ./nitellad-rs/bench/profile_syscalls.sh
```

The short local profile on April 21, 2026 KST used 50 connections, 2 seconds of
warmup, and 8 seconds of load:

| Scenario | `splice` calls | `splice` EAGAIN/errors | `epoll_wait` calls | `epoll_ctl` calls |
| --- | ---: | ---: | ---: | ---: |
| small_req | 1,410,788 | 470,925 | 347 | 612 |
| large_1m | 1,147,687 | 62,749 | 480 | 612 |
| stream_1m | 901,708 | 70,423 | 16,322 | 612 |

The syscall-count shape shows the current Linux path is dominated by
`splice(2)` attempts and EAGAIN handling, not repeated epoll registration.
`epoll_ctl` is effectively one-time connection setup.

To check whether this host can run an io_uring splice experiment:

```bash
cargo run --release --manifest-path nitellad-rs/Cargo.toml --bin io_uring_probe
```

On this host, the probe reports `IORING_OP_SPLICE: supported` when run outside
the sandbox.

The isolated io_uring splice prototype can be compared with the production
Rust epoll+splice path with:

```bash
IOURING_BENCH_WARMUP=5 IOURING_BENCH_DURATION=15 ./nitellad-rs/bench/io_uring_compare.sh
```

Local result on April 21, 2026 KST:

| Scenario | Variant | Requests/sec | Transfer/sec | p50 latency | p99 latency |
| --- | --- | ---: | ---: | ---: | ---: |
| small_req | Rust epoll+splice | 143,283 | 14.62MB/s | 245us | 1.28ms |
| small_req | io_uring prototype | 72,291 | 7.38MB/s | 516us | 2.07ms |
| large_1m | Rust epoll+splice | 4,567 | 4.46GB/s | 6.30ms | 17.11ms |
| large_1m | io_uring prototype | 4,322 | 4.22GB/s | 7.61ms | 17.62ms |
| stream_1m | Rust epoll+splice | 1,648 | 1.61GB/s | 22.19ms | 70.35ms |
| stream_1m | io_uring prototype | 1,449 | 1.42GB/s | 32.16ms | 52.49ms |

Conclusion from this step: the bench-only io_uring prototype is functional, but
it is slower than the current shared `epoll(7)` + `splice(2)` reactor, so the
production Linux data path remains epoll+splice.

### Latest Benchmark Snapshot

Latest local benchmark source:

```text
nitellad-rs/bench/results/summary.json
```

This snapshot was generated on April 21, 2026 KST with:

- runs: 1
- scenarios: `small_req`, `large_1m`, and `stream_1m`
- warmup: 10 seconds
- threads: 4
- load: 50 connections for 30 seconds
- load generator: `wrk`
- backend: static TCP HTTP backend (`bench_backend`)
- leak check: disabled for this quick data-path comparison (`LEAK_CYCLES=0`)
- Rust raw TCP data path: Linux sharded `epoll(7)` + `splice(2)` reactor by
  default
- environment: `GOMAXPROCS=unset`, `BACKEND_TASKSET=unset`, and
  `DAEMON_TASKSET=unset`
- variants: Go/Rust, standard/process mode

| Scenario | Variant | Requests/sec | Transfer | p50 latency | p99 latency | Socket errors | Peak RSS | Peak threads | Avg CPU | Backend CPU |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| small_req | Go standard | 140,130 | 14.30MiB/s | 0.24ms | 1190.00ms | 4 | 37.0MB | 29 | 486.6% | 218.8% |
| small_req | Go process | 145,319 | 14.83MiB/s | 0.23ms | 2.82ms | 0 | 53.6MB | 39 | 518.0% | 232.2% |
| small_req | Rust standard | 146,820 | 14.98MiB/s | 0.24ms | 1.24ms | 0 | 20.2MB | 37 | 517.6% | 237.8% |
| small_req | Rust process | 144,047 | 14.70MiB/s | 0.25ms | 1.12ms | 0 | 36.5MB | 51 | 529.4% | 242.8% |
| large_1m | Go standard | 5,114 | 5109.76MiB/s | 6.38ms | 834.69ms | 0 | 36.0MB | 27 | 315.8% | 363.1% |
| large_1m | Go process | 5,253 | 5253.12MiB/s | 6.29ms | 15.90ms | 0 | 52.7MB | 34 | 330.9% | 384.4% |
| large_1m | Rust standard | 5,425 | 5427.20MiB/s | 5.36ms | 14.00ms | 0 | 19.9MB | 37 | 282.1% | 404.4% |
| large_1m | Rust process | 5,424 | 5427.20MiB/s | 5.32ms | 13.76ms | 0 | 36.4MB | 51 | 283.9% | 397.2% |
| stream_1m | Go standard | 1,397 | 1402.88MiB/s | 31.48ms | 1090.00ms | 0 | 36.1MB | 33 | 319.6% | 662.1% |
| stream_1m | Go process | 1,444 | 1443.84MiB/s | 31.14ms | 60.67ms | 0 | 52.5MB | 43 | 335.9% | 699.5% |
| stream_1m | Rust standard | 1,557 | 1556.48MiB/s | 23.70ms | 72.79ms | 0 | 20.0MB | 37 | 209.1% | 616.7% |
| stream_1m | Rust process | 1,507 | 1505.28MiB/s | 23.93ms | 72.64ms | 0 | 36.9MB | 51 | 211.3% | 611.6% |

Summary from this run:

- Linux raw TCP now uses a sharded non-Tokio `epoll(7)` + `splice(2)` reactor
  by default.
- On the small-response request-rate profile, Rust standard measured 146,820
  req/s vs Go standard at 140,130 req/s. Rust process measured 144,047 req/s vs
  Go process at 145,319 req/s.
- On the 1MiB fixed-response profile, Rust standard measured 5427.20MiB/s vs Go
  standard at 5109.76MiB/s. Rust process measured 5427.20MiB/s vs Go process at
  5253.12MiB/s.
- On the finite chunked-stream profile, Rust standard measured 1556.48MiB/s vs
  Go standard at 1402.88MiB/s. Rust process measured 1505.28MiB/s vs Go process
  at 1443.84MiB/s.
- Go standard had large p99 outliers in this local run, and the small-response
  Go standard row also reported 4 socket errors. Treat the Go standard tail
  rows as outlier-sensitive single-run data.
- The Rust standard peak thread count stayed at 37 during 50-connection loads,
  confirming that raw TCP splice is no longer using one OS thread per proxied
  connection.
- The previous per-connection epoll splice draft measured 133,325 req/s
  standard and 128,430 req/s process. The shared reactor recovered the gap by
  removing per-connection epoll fds and per-connection worker threads.
- A previous quick no-splice blocking-copy run, before making splice the Linux
  default and removing the flag, measured 154,768 req/s standard and 160,565
  req/s process. That path remains a useful reference, but it copies payloads
  through userspace and is not the Linux default.
- The non-Linux raw TCP and wrapped fallback copy paths now use the same fixed
  32KB userspace buffer as Go.
- Leak checks were disabled for this quick data-path comparison
  (`LEAK_CYCLES=0`), so goroutine leak columns in the generated summary are
  intentionally `N/A`.

Important notes:

- The benchmark starts one local Rust backend process and one proxy process per
  variant.
- The benchmark records backend CPU separately from proxy CPU in
  `summary.json`.
- The benchmark uses fixed local ports from `bench/benchmark.sh`.
- The benchmark may stop existing `nitellad` or `nitellad-rs` benchmark
  processes during cleanup.
- The benchmark builds temporary binaries under `/tmp`.

## Compatibility Smoke Tests

Several scripts under `scripts/` exercise Rust daemon compatibility with the Go
client/test harness:

```bash
bash scripts/test_nitellad_cli_nohub_compat.sh
bash scripts/test_nitellad_rs_direct_admin_smoke.sh
bash scripts/test_nitellad_rs_process_mode_smoke.sh
bash scripts/test_nitellad_rs_config_smoke.sh
bash scripts/test_nitellad_rs_persistence_smoke.sh
bash scripts/test_nitellad_rs_hub_pairing_smoke.sh
```

The broader compatibility comparison is:

```bash
bash scripts/compare_nitellad_compat.sh
```

## Current Status

Use `cmd/nitellad` for the default daemon path unless you are explicitly working
on Rust compatibility or benchmarking.

Use `nitellad-rs` when you need to:

- compare Go and Rust daemon performance
- test daemon compatibility from a second implementation
- investigate resource usage or process-mode behavior
- prototype Rust-side changes before deciding whether they belong in the main
  Go daemon
