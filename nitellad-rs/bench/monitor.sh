#!/bin/bash
# Resource monitor using /proc for instantaneous CPU% and RSS.
# Outputs CSV: Timestamp,RSS_KB,CPU_Percent

TARGET_PID=$1
OUTPUT_FILE=$2
INTERVAL=${3:-1}  # sampling interval in seconds

if [ -z "$TARGET_PID" ] || [ -z "$OUTPUT_FILE" ]; then
    echo "Usage: $0 <pid> <output_file> [interval_seconds]"
    exit 1
fi

CLK_TCK=$(getconf CLK_TCK)
PAGE_SIZE=$(getconf PAGE_SIZE)
PAGE_SIZE_KB=$((PAGE_SIZE / 1024))

# Read cumulative CPU ticks (utime + stime) for a single PID from /proc.
# Returns empty string if process doesn't exist.
read_cpu_ticks() {
    local pid=$1
    local stat_file="/proc/$pid/stat"
    [ -f "$stat_file" ] || return
    # Fields 14 (utime) and 15 (stime) are 1-indexed in the stat file.
    # awk splits by space; the comm field (field 2) can contain spaces and parens,
    # so we strip everything up to the closing paren first.
    awk '{
        sub(/^[0-9]+ \([^)]*\) /, "")
        # Now field 1 = state, field 12 = utime (was 14), field 13 = stime (was 15)
        print $12 + $13
    }' "$stat_file" 2>/dev/null
}

# Read RSS in KB for a single PID from /proc.
read_rss_kb() {
    local pid=$1
    local stat_file="/proc/$pid/statm"
    [ -f "$stat_file" ] || return
    # Field 2 of statm is RSS in pages
    awk -v pskb="$PAGE_SIZE_KB" '{print $2 * pskb}' "$stat_file" 2>/dev/null
}

# Collect all PIDs: target + descendants (recursive)
collect_pids() {
    local parent=$1
    local pids="$parent"
    local children
    children=$(pgrep -P "$parent" 2>/dev/null)
    for child in $children; do
        pids="$pids $child"
        # Also get grandchildren
        local grandchildren
        grandchildren=$(pgrep -P "$child" 2>/dev/null)
        for gc in $grandchildren; do
            pids="$pids $gc"
        done
    done
    echo "$pids"
}

echo "Timestamp,RSS_KB,CPU_Percent" > "$OUTPUT_FILE"

# Take initial reading
PREV_TICKS=0
ALL_PIDS=$(collect_pids "$TARGET_PID")
for pid in $ALL_PIDS; do
    ticks=$(read_cpu_ticks "$pid")
    if [ -n "$ticks" ]; then
        PREV_TICKS=$((PREV_TICKS + ticks))
    fi
done
PREV_TIME=$(date +%s%N)  # nanoseconds

sleep "$INTERVAL"

while kill -0 "$TARGET_PID" 2>/dev/null; do
    NOW_TIME=$(date +%s%N)
    ALL_PIDS=$(collect_pids "$TARGET_PID")

    CURR_TICKS=0
    TOTAL_RSS=0

    for pid in $ALL_PIDS; do
        ticks=$(read_cpu_ticks "$pid")
        if [ -n "$ticks" ]; then
            CURR_TICKS=$((CURR_TICKS + ticks))
        fi

        rss=$(read_rss_kb "$pid")
        if [ -n "$rss" ]; then
            TOTAL_RSS=$((TOTAL_RSS + rss))
        fi
    done

    # CPU%: (delta_ticks / CLK_TCK) / (delta_wall_seconds) * 100
    DELTA_TICKS=$((CURR_TICKS - PREV_TICKS))
    DELTA_NS=$((NOW_TIME - PREV_TIME))

    if [ "$DELTA_NS" -gt 0 ]; then
        # CPU% = (DELTA_TICKS * 1e9 * 100) / (CLK_TCK * DELTA_NS)
        # Use awk for floating point
        CPU_PCT=$(awk -v dt="$DELTA_TICKS" -v clk="$CLK_TCK" -v dns="$DELTA_NS" \
            'BEGIN { printf "%.1f", (dt * 1000000000 * 100) / (clk * dns) }')
    else
        CPU_PCT="0.0"
    fi

    TIMESTAMP=$(date +%s)
    echo "$TIMESTAMP,$TOTAL_RSS,$CPU_PCT" >> "$OUTPUT_FILE"

    PREV_TICKS=$CURR_TICKS
    PREV_TIME=$NOW_TIME

    sleep "$INTERVAL"
done
