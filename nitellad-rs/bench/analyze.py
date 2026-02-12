#!/usr/bin/env python3
"""
Analyze Nitella benchmark results.

Parses wrk output files, resource CSVs, and RSS drift data to produce:
  - results/summary.json  (structured, machine-readable)
  - results/summary.md    (markdown table for humans)

Usage: python3 analyze.py <results_dir>
"""

import csv
import json
import os
import re
import statistics
import sys


def parse_wrk_output(filepath):
    """Parse a wrk output file and return extracted metrics."""
    result = {
        "requests_sec": None,
        "latency_avg": None,
        "latency_stdev": None,
        "latency_max": None,
        "latency_p50": None,
        "latency_p75": None,
        "latency_p90": None,
        "latency_p99": None,
        "total_requests": None,
        "non_2xx": 0,
        "transfer_sec": None,
    }

    if not os.path.exists(filepath):
        return result

    with open(filepath, "r") as f:
        content = f.read()

    # Requests/sec:  10000.00
    m = re.search(r"Requests/sec:\s+([\d.]+)", content)
    if m:
        result["requests_sec"] = float(m.group(1))

    # Transfer/sec:      1.17MB
    m = re.search(r"Transfer/sec:\s+([\d.]+\S+)", content)
    if m:
        result["transfer_sec"] = m.group(1)

    # Latency line:   Latency     1.23ms  456.78us  12.34ms   78.90%
    m = re.search(r"Latency\s+([\d.]+\S+)\s+([\d.]+\S+)\s+([\d.]+\S+)", content)
    if m:
        result["latency_avg"] = parse_duration_to_ms(m.group(1))
        result["latency_stdev"] = parse_duration_to_ms(m.group(2))
        result["latency_max"] = parse_duration_to_ms(m.group(3))

    # Latency Distribution percentiles
    for pct, key in [("50%", "latency_p50"), ("75%", "latency_p75"),
                     ("90%", "latency_p90"), ("99%", "latency_p99")]:
        m = re.search(rf"\s+{re.escape(pct)}\s+([\d.]+\S+)", content)
        if m:
            result[key] = parse_duration_to_ms(m.group(1))

    # Total requests: 300000 requests in 30.00s
    m = re.search(r"(\d+)\s+requests\s+in", content)
    if m:
        result["total_requests"] = int(m.group(1))

    # Non-2xx responses: 1234
    m = re.search(r"Non-2xx responses:\s+(\d+)", content)
    if m:
        result["non_2xx"] = int(m.group(1))

    return result


def parse_duration_to_ms(s):
    """Convert wrk duration string (e.g., '1.23ms', '456.78us', '1.50s') to milliseconds."""
    s = s.strip()
    if s.endswith("ms"):
        return float(s[:-2])
    elif s.endswith("us"):
        return float(s[:-2]) / 1000.0
    elif s.endswith("s"):
        return float(s[:-1]) * 1000.0
    elif s.endswith("m"):
        return float(s[:-1]) * 60000.0
    return None


def parse_resources_csv(filepath):
    """Parse resource CSV and return max RSS (MB), avg CPU%, peak CPU%."""
    max_rss_kb = 0
    total_cpu = 0.0
    peak_cpu = 0.0
    count = 0

    if not os.path.exists(filepath):
        return 0.0, 0.0, 0.0

    with open(filepath, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                rss = int(row["RSS_KB"])
                cpu = float(row["CPU_Percent"])
                max_rss_kb = max(max_rss_kb, rss)
                total_cpu += cpu
                peak_cpu = max(peak_cpu, cpu)
                count += 1
            except (ValueError, KeyError):
                continue

    avg_cpu = total_cpu / count if count > 0 else 0.0
    return max_rss_kb / 1024.0, avg_cpu, peak_cpu


def parse_resource_summary(filepath):
    """Parse the JSON summary file produced by monitor_full.sh."""
    if not os.path.exists(filepath):
        return 0.0
    try:
        with open(filepath, "r") as f:
            data = json.load(f)
            return data.get("total_cpu_seconds", 0.0)
    except (json.JSONDecodeError, ValueError):
        return 0.0


def read_rss_file(filepath):
    """Read a single RSS value from a text file (in KB)."""
    try:
        with open(filepath, "r") as f:
            val = f.read().strip()
            return int(val) if val and val != "0" else 0
    except (FileNotFoundError, ValueError):
        return 0


def parse_pprof_snapshot(filepath):
    """Parse a pprof JSON snapshot file."""
    if not os.path.exists(filepath):
        return None
    try:
        with open(filepath, "r") as f:
            return json.load(f)
    except (json.JSONDecodeError, ValueError):
        return None


def compute_pprof_drift(results_dir, run_tag, leak_cycles):
    """Compute goroutine and heap drift from pprof snapshots."""
    before = parse_pprof_snapshot(
        os.path.join(results_dir, f"{run_tag}_pprof_before.json")
    )
    after_load = parse_pprof_snapshot(
        os.path.join(results_dir, f"{run_tag}_pprof_after_load.json")
    )

    # Use last leak cycle's after snapshot as final
    final = None
    for cycle in range(leak_cycles, 0, -1):
        final = parse_pprof_snapshot(
            os.path.join(results_dir, f"{run_tag}_pprof_leak_cycle{cycle}_after.json")
        )
        if final:
            break

    if not before:
        return None

    result = {
        "goroutines_before": before.get("goroutines", 0),
        "goroutines_after_load": after_load.get("goroutines", 0) if after_load else 0,
        "goroutines_final": final.get("goroutines", 0) if final else 0,
        "heap_inuse_before": before.get("heap_inuse", 0),
        "heap_inuse_after_load": after_load.get("heap_inuse", 0) if after_load else 0,
        "heap_inuse_final": final.get("heap_inuse", 0) if final else 0,
    }

    result["goroutine_leak"] = result["goroutines_final"] - result["goroutines_before"]
    result["heap_inuse_drift"] = result["heap_inuse_final"] - result["heap_inuse_before"]

    return result


def compute_rss_drift(results_dir, run_tag, leak_cycles):
    """Compute RSS drift across leak detection cycles."""
    rss_after_values = []
    for cycle in range(1, leak_cycles + 1):
        rss_after = read_rss_file(
            os.path.join(results_dir, f"{run_tag}_rss_after_cycle{cycle}.txt")
        )
        if rss_after > 0:
            rss_after_values.append(rss_after)

    if len(rss_after_values) >= 2:
        drift_kb = rss_after_values[-1] - rss_after_values[0]
        drift_pct = (drift_kb / rss_after_values[0] * 100) if rss_after_values[0] > 0 else 0
        return {
            "rss_after_cycle_kb": rss_after_values,
            "drift_kb": drift_kb,
            "drift_pct": round(drift_pct, 2),
        }
    return {"rss_after_cycle_kb": rss_after_values, "drift_kb": 0, "drift_pct": 0.0}


def safe_median(values):
    return round(statistics.median(values), 2) if values else None


def safe_mean(values):
    return round(statistics.mean(values), 2) if values else None


def analyze_variant(results_dir, variant, runs, leak_cycles):
    """Analyze all runs for a given variant."""
    run_results = []
    all_rps = []
    all_p50 = []
    all_p99 = []
    all_max_rss = []
    all_avg_cpu = []
    all_peak_cpu = []
    all_total_cpu_sec = []

    for run_num in range(1, runs + 1):
        run_tag = f"{variant}_run{run_num}"

        # Parse wrk high-load output
        wrk_file = os.path.join(results_dir, f"{run_tag}_wrk_load.txt")
        wrk = parse_wrk_output(wrk_file)

        # Parse resources
        res_file = os.path.join(results_dir, f"{run_tag}_resources.csv")
        max_rss_mb, avg_cpu, peak_cpu = parse_resources_csv(res_file)
        
        # Parse resource summary (Total CPU Time)
        cpu_time = parse_resource_summary(f"{res_file}.summary")

        # RSS drift
        drift = compute_rss_drift(results_dir, run_tag, leak_cycles)

        # pprof data (Go only)
        pprof_drift = compute_pprof_drift(results_dir, run_tag, leak_cycles)

        run_data = {
            "run": run_num,
            "requests_sec": wrk["requests_sec"],
            "latency_avg_ms": wrk["latency_avg"],
            "latency_p50_ms": wrk["latency_p50"],
            "latency_p99_ms": wrk["latency_p99"],
            "latency_max_ms": wrk["latency_max"],
            "total_requests": wrk["total_requests"],
            "non_2xx": wrk["non_2xx"],
            "max_rss_mb": round(max_rss_mb, 2),
            "avg_cpu_pct": round(avg_cpu, 1),
            "peak_cpu_pct": round(peak_cpu, 1),
            "total_cpu_sec": cpu_time,
            "rss_drift": drift,
            "pprof": pprof_drift,
        }
        run_results.append(run_data)

        if wrk["requests_sec"] is not None:
            all_rps.append(wrk["requests_sec"])
        if wrk["latency_p50"] is not None:
            all_p50.append(wrk["latency_p50"])
        if wrk["latency_p99"] is not None:
            all_p99.append(wrk["latency_p99"])
        if max_rss_mb > 0:
            all_max_rss.append(max_rss_mb)
        if avg_cpu > 0:
            all_avg_cpu.append(avg_cpu)
        if peak_cpu > 0:
            all_peak_cpu.append(peak_cpu)
        if cpu_time > 0:
            all_total_cpu_sec.append(cpu_time)

    # Aggregate drift across runs
    all_drift_kb = [r["rss_drift"]["drift_kb"] for r in run_results if r["rss_drift"]["drift_kb"] != 0]

    # Aggregate pprof data (Go runs only)
    all_goroutine_leak = [r["pprof"]["goroutine_leak"] for r in run_results if r["pprof"]]
    all_heap_inuse_drift = [r["pprof"]["heap_inuse_drift"] for r in run_results if r["pprof"]]

    return {
        "runs": run_results,
        "median_rps": safe_median(all_rps),
        "median_p50_ms": safe_median(all_p50),
        "median_p99_ms": safe_median(all_p99),
        "peak_rss_mb": round(max(all_max_rss), 2) if all_max_rss else None,
        "mean_rss_mb": safe_mean(all_max_rss),
        "avg_cpu_pct": safe_mean(all_avg_cpu),
        "peak_cpu_pct": round(max(all_peak_cpu), 1) if all_peak_cpu else None,
        "mean_total_cpu_sec": safe_mean(all_total_cpu_sec),
        "mean_rss_drift_kb": safe_mean(all_drift_kb) if all_drift_kb else 0,
        "total_non_2xx": sum(r["non_2xx"] for r in run_results),
        "mean_goroutine_leak": safe_mean(all_goroutine_leak) if all_goroutine_leak else None,
        "mean_heap_inuse_drift": safe_mean(all_heap_inuse_drift) if all_heap_inuse_drift else None,
    }


def format_variant_name(variant):
    """Make variant names readable (e.g. go_process_short -> Go Process Short)."""
    # Replace known terms for better casing
    s = variant.replace("_", " ").title()
    s = s.replace("Go", "Go").replace("Rust", "Rust").replace("Std", "Standard")
    return s


def generate_markdown(summary, config):
    """Generate a markdown summary table."""
    lines = []
    lines.append(f"# Nitella Comprehensive Benchmark Results")
    lines.append("")
    lines.append(f"**Runs per variant:** {config['runs']}  ")
    if "scenarios" in config:
        lines.append("**Scenarios tested:**")
        for s_name, s_args in config["scenarios"].items():
            lines.append(f"- **{s_name}:** {s_args}")
    lines.append("")

    # Main performance table
    lines.append("## Performance")
    lines.append("")
    # Added "CPU Time (s)" column
    lines.append("| Variant | Median Req/s | p50 (ms) | p99 (ms) | Non-2xx | Peak RSS (MB) | Avg CPU (%) | CPU Time (s) | RSS Drift (KB) | Goroutine Leak |")
    lines.append("|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|")

    for variant in config["variants"]:
        data = summary.get(variant)
        if not data:
            continue
        readable_name = format_variant_name(variant)

        rps = f"{data['median_rps']:.0f}" if data["median_rps"] else "N/A"
        p50 = f"{data['median_p50_ms']:.2f}" if data["median_p50_ms"] else "N/A"
        p99 = f"{data['median_p99_ms']:.2f}" if data["median_p99_ms"] else "N/A"
        non2xx = str(data["total_non_2xx"])
        rss = f"{data['peak_rss_mb']:.1f}" if data["peak_rss_mb"] else "N/A"
        cpu = f"{data['avg_cpu_pct']:.1f}" if data["avg_cpu_pct"] else "N/A"
        cpu_time = f"{data['mean_total_cpu_sec']:.2f}" if data["mean_total_cpu_sec"] is not None else "N/A"
        drift = f"{data['mean_rss_drift_kb']:.0f}" if data["mean_rss_drift_kb"] else "0"
        gleak = f"{data['mean_goroutine_leak']:.0f}" if data.get("mean_goroutine_leak") is not None else "N/A"

        lines.append(f"| {readable_name} | {rps} | {p50} | {p99} | {non2xx} | {rss} | {cpu} | {cpu_time} | {drift} | {gleak} |")

    lines.append("")
    lines.append("## Leak Detection Details")
    lines.append("")
    
    for variant in config["variants"]:
        data = summary.get(variant)
        if not data:
            continue
        readable_name = format_variant_name(variant)

        # Only show detailed logs if there are issues or just for the first run to keep it clean?
        # Let's show all for now as per "comprehensive" request.
        for run_data in data["runs"]:
            drift_info = run_data["rss_drift"]
            drift_pct = drift_info.get("drift_pct", 0)
            status = "PASS" if abs(drift_pct) < 10 else "WARN"
            
            detail = (
                f"- **{readable_name}** run {run_data['run']}: "
                f"RSS drift={drift_info['drift_kb']}KB ({drift_pct:.1f}%) [{status}]"
            )

            pprof = run_data.get("pprof")
            if pprof:
                gleak = pprof["goroutine_leak"]
                g_status = "PASS" if abs(gleak) <= 5 else "WARN"
                detail += (
                    f" | goroutines: {pprof['goroutines_before']}->{pprof['goroutines_final']}"
                    f" (leak={gleak}) [{g_status}]"
                )

            lines.append(detail)

    lines.append("")
    return "\n".join(lines)


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 analyze.py <results_dir>")
        sys.exit(1)

    results_dir = sys.argv[1]

    # Load config
    config_path = os.path.join(results_dir, "config.json")
    if not os.path.exists(config_path):
        print(f"Config not found: {config_path}")
        sys.exit(1)

    with open(config_path, "r") as f:
        config = json.load(f)

    runs = config["runs"]
    leak_cycles = config["leak_cycles"]
    variants = config["variants"]

    summary = {}
    for variant in variants:
        summary[variant] = analyze_variant(results_dir, variant, runs, leak_cycles)

    # Write JSON
    json_path = os.path.join(results_dir, "summary.json")
    with open(json_path, "w") as f:
        json.dump({"config": config, "results": summary}, f, indent=2)
    print(f"Written: {json_path}")

    # Write markdown
    md_content = generate_markdown(summary, config)
    md_path = os.path.join(results_dir, "summary.md")
    with open(md_path, "w") as f:
        f.write(md_content)
    print(f"Written: {md_path}")

    # Also print markdown to stdout
    print()
    print(md_content)


if __name__ == "__main__":
    main()