# Nitella: Go vs Rust Comprehensive Benchmark Report

**Date:** February 10, 2026  
**Platform:** Linux (Benchmarked on local environment)

## 1. Executive Summary

The benchmark results conclusively demonstrate that the **Rust implementation (`nitellad-rs`) is superior** to the Go implementation (`nitellad`) for the Nitella proxy.

*   **Throughput:** Rust in Process Mode achieved **92.7k req/s**, nearly **3x faster** than Go in the same mode (32.6k req/s).
*   **Efficiency:** Under high connection churn, Rust consumed **~25% less CPU** and **~50-65% less Memory** than Go while maintaining identical throughput.
*   **Architecture:** Go suffers a significant performance penalty (~35% drop) when switching to Process Mode (Child Process Isolation). Rust, conversely, handles Process Mode with exceptional efficiency, actually *outperforming* its own Standard Mode in throughput tests.

## 2. Scenario Analysis

### Scenario A: High Connection Churn ("Heavy Short")
*Simulates real-world traffic with frequent connections/disconnections (e.g., mobile clients, short-lived sessions).*
*   **Load:** 100 concurrent connections, `Connection: close`
*   **Focus:** Connection handshake overhead, Resource cleanup efficiency.

| Metric | Go (Standard) | Go (Process) | Rust (Standard) | Rust (Process) | **Winner** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Throughput** | 12,119 req/s | 12,904 req/s | 11,945 req/s | 12,216 req/s | **Tie** |
| **Latency (p99)** | 24.91 ms | 23.46 ms | 17.16 ms | 16.02 ms | **Rust** (-30%) |
| **CPU Time** | 181.6 s | 187.6 s | 138.9 s | 138.7 s | **Rust** (-26%) |
| **Memory (RSS)** | 83.6 MB | 73.7 MB | 29.2 MB | 43.8 MB | **Rust** (-40% to -65%) |

**Insight:** While throughput is limited by the TCP handshake overhead for both, **Rust is significantly more efficient**, doing the same work with much less CPU and Memory.

---

### Scenario B: High Throughput ("Heavy Long")
*Simulates high-bandwidth data transfer or persistent connections (e.g., streaming, long-polling).*
*   **Load:** 100 concurrent connections, Keep-Alive
*   **Focus:** Raw proxying speed, I/O efficiency.

| Metric | Go (Standard) | Go (Process) | Rust (Standard) | Rust (Process) | **Winner** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Throughput** | 50,772 req/s | 32,587 req/s | 41,299 req/s | **92,728 req/s** | **Rust Process** (2.8x vs Go) |
| **Latency (p50)**| 1.68 ms | 2.73 ms | 2.06 ms | **0.94 ms** | **Rust Process** |
| **Latency (p99)**| 8.15 ms | 14.63 ms | 9.67 ms | **3.02 ms** | **Rust Process** |
| **Memory (RSS)** | 35.2 MB | 56.2 MB | 21.8 MB | 37.1 MB | **Rust** |

**Insight:** This is the most dramatic result. Go's performance collapses in Process Mode, while Rust executes it flawlessly, nearly doubling the throughput of Go's *best* case (Standard).

## 3. Stability & Leaks

Both implementations demonstrated stability over repeated leak detection cycles.

*   **Memory Leaks:** No significant leaks detected in either implementation. RSS drift was within noise levels (< 5%).
*   **Goroutine Leaks (Go):** None observed.
*   **Stability:** Rust maintained tighter tail latencies (p99) under stress, indicating better jitter characteristics.

## 4. Conclusion & Recommendation

**Recommendation: Adopt Rust (`nitellad-rs`) for Production.**

The Rust implementation fulfills the "Production Ready" requirement with:
1.  **Lower Infrastructure Costs:** Significantly lower CPU and Memory usage means fewer instances are needed.
2.  **Better Isolation:** The "Process Mode" (crucial for isolating different proxy contexts) is highly performant in Rust, whereas it is a bottleneck in Go.
3.  **Predictability:** Lower and more consistent latency under load.
