#!/bin/bash
# Wait for a service to be available
# Usage: wait_for_service.sh <host> <port> [timeout]

HOST=$1
PORT=$2
TIMEOUT=${3:-60}

start=$(date +%s)
while ! nc -z "$HOST" "$PORT" 2>/dev/null; do
    elapsed=$(($(date +%s) - start))
    if [ $elapsed -gt $TIMEOUT ]; then
        echo "Timeout waiting for $HOST:$PORT"
        exit 1
    fi
    echo "Waiting for $HOST:$PORT..."
    sleep 1
done

echo "$HOST:$PORT is available"
