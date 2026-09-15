#!/bin/bash

IP=8.8.8.8

LOG_FILE="current-logs/uplink-ping-$(date "+%F").log"
exec >> "$LOG_FILE" 2>&1

start_date=$(date +%F)
while [ "$(date +%F)" = "$start_date" ]; do
	if ping -c 1 -W 1 "$IP" > /dev/null 2<&1; then
		echo "PASS time=$(date "+%F_%H-%M-%S")"
	else
		echo "FAIL time=$(date "+%F_%H-%M-%S")"
	fi
	sleep 1
done

mv $LOG_FILE old-logs
