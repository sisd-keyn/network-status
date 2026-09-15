#!/bin/bash
set -euo pipefail

TARGET_IP="${TARGET_IP:-8.8.8.8}"
PING_INTERVAL="${PING_INTERVAL:-1}"
DB_PATH="${DB_PATH:-/data/pings.db}"

sqlite3 "$DB_PATH" <<EOF
PRAGMA journal_mode=WAL;
CREATE TABLE IF NOT EXISTS pings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT NOT NULL,
    success INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_pings_timestamp ON pings(timestamp);
EOF

echo "Starting ping monitor for $TARGET_IP every ${PING_INTERVAL}s, writing to $DB_PATH"

# Main Loop
while true; do
	timestamp=$(date -u "+%Y-%m-%dT%H:%M:%SZ")

	if ping -c 1 -W 1 "$TARGET_IP" > /dev/null 2>&1; then
		success=1
	else
		success=0
	fi

	sqlite3 "$DB_PATH" "INSERT INTO pings (timestamp, success) VALUES ('$timestamp', $success);"

	sleep "$PING_INTERVAL"
done
