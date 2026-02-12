#!/bin/bash
# Resource monitor using /proc for instantaneous CPU% and RSS.
# Also calculates cumulative CPU time (User + Sys).
# Outputs CSV: Timestamp,RSS_KB,CPU_Percent
# Outputs Summary on exit: <output_file>.summary containing JSON

TARGET_PID=$1
OUTPUT_FILE=$2
INTERVAL=${3:-1}

if [ -z "$TARGET_PID" ] || [ -z "$OUTPUT_FILE" ]; then
    echo "Usage: $0 <pid> <output_file> [interval_seconds]"
    exit 1
fi

CLK_TCK=$(getconf CLK_TCK)
PAGE_SIZE=$(getconf PAGE_SIZE)
PAGE_SIZE_KB=$((PAGE_SIZE / 1024))

# Read cumulative CPU ticks (utime + stime) for a single PID
read_cpu_ticks() {
    local pid=$1
    local stat_file="/proc/$pid/stat"
    [ -f "$stat_file" ] || return
    awk '{
        sub(/^[0-9]+ \([^)]*\) /, "")
        print $12 + $13
    }' "$stat_file" 2>/dev/null
}

# Read RSS in KB for a single PID
read_rss_kb() {
    local pid=$1
    local stat_file="/proc/$pid/statm"
    [ -f "$stat_file" ] || return
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
        local grandchildren
        grandchildren=$(pgrep -P "$child" 2>/dev/null)
        for gc in $grandchildren; do
            pids="$pids $gc"
        done
    done
    echo "$pids"
}

# Cleanup and summarize function
cleanup() {
    local END_TIME=$(date +%s%N)
    local TOTAL_TICKS=0
    
    local TOTAL_SECONDS
    if [ "$START_TICKS" -gt 0 ]; then
         TOTAL_SECONDS=$(awk -v ticks="$ACCUMULATED_TICKS" -v clk="$CLK_TCK" 'BEGIN { printf "%.3f", ticks / clk }')
    else
         TOTAL_SECONDS="0.000"
    fi

    echo "{\"total_cpu_seconds\": $TOTAL_SECONDS}" > "${OUTPUT_FILE}.summary"
    exit 0
}

trap cleanup SIGTERM SIGINT

echo "Timestamp,RSS_KB,CPU_Percent" > "$OUTPUT_FILE"

# Initial State
START_TIME=$(date +%s%N)
PREV_TIME=$START_TIME
PREV_TICKS=0
ACCUMULATED_TICKS=0

# Initialize PREV_TICKS
ALL_PIDS=$(collect_pids "$TARGET_PID")
for pid in $ALL_PIDS; do
    ticks=$(read_cpu_ticks "$pid")
    if [ -n "$ticks" ]; then
        PREV_TICKS=$((PREV_TICKS + ticks))
    fi
done
START_TICKS=$PREV_TICKS

# Main Loop
while kill -0 "$TARGET_PID" 2>/dev/null; do
    sleep "$INTERVAL"
    
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

    # If the process died during sleep, CURR_TICKS might be 0 or partial.
    DELTA_TICKS=$((CURR_TICKS - PREV_TICKS))
    
    # Handle case where pids disappear (DELTA_TICKS negative)
    if [ "$DELTA_TICKS" -lt 0 ]; then
        DELTA_TICKS=0 
    fi
    
    ACCUMULATED_TICKS=$((ACCUMULATED_TICKS + DELTA_TICKS))
    
    DELTA_NS=$((NOW_TIME - PREV_TIME))
    
    CPU_PCT="0.0"
    if [ "$DELTA_NS" -gt 0 ]; then
        CPU_PCT=$(awk -v dt="$DELTA_TICKS" -v clk="$CLK_TCK" -v dns="$DELTA_NS" \
            'BEGIN { printf "%.1f", (dt * 1000000000 * 100) / (clk * dns) }')
    fi

    TIMESTAMP=$(date +%s)
    echo "$TIMESTAMP,$TOTAL_RSS,$CPU_PCT" >> "$OUTPUT_FILE"

    PREV_TICKS=$CURR_TICKS
    PREV_TIME=$NOW_TIME
done

cleanup