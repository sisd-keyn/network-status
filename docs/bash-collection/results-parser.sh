#!/bin/bash

# Require exactly one argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <logfile>"
    exit 1
fi

logfile="$1"

# Check that the file actually exists
if [ ! -f "$logfile" ]; then
    echo "Error: '$logfile' not found."
    exit 1
fi

start_time=$(head -n1 $logfile | cut -d '_' -f2)
end_time=$(tail -n1 $logfile | cut -d '_' -f2)
echo "Start Time: $start_time"
echo "End Time: $end_time"

calc_time_diff() {
	t1="$1"
	t2="$2"

	t1h=$(echo "$t1" | cut -d '-' -f1)
	t1m=$(echo "$t1" | cut -d '-' -f2)
	t1s=$(echo "$t1" | cut -d '-' -f3)

	t2h=$(echo "$t2" | cut -d '-' -f1)
	t2m=$(echo "$t2" | cut -d '-' -f2)
	t2s=$(echo "$t2" | cut -d '-' -f3)

	diff=0
	diff=$(( diff+(10#$t2h-10#$t1h)*60*60 ))
	diff=$(( diff+(10#$t2m-10#$t1m)*60 ))
	diff=$(( diff+(10#$t2s-10#$t1s) ))

	echo $diff
}

outage_period=false
outage_start=00-00-00
outage_end=00-00-00
line_pass=true
total_outage_time=0
while IFS= read -r line; do
	line_pass=$(echo "$line" | cut -d ' ' -f1)
	if [[ $line_pass == "PASS" ]]; then
		line_pass=true
	elif [[ $line_pass == "FAIL" ]]; then
		line_pass=false
	else
		:
		# This condition means there's an error somewhere. 
	fi
	if $outage_period; then
		if $line_pass; then
			outage_period=false
			outage_end=$(echo "$line" | cut -d '_' -f2)
			outage_length=$(calc_time_diff $outage_start $outage_end)
			echo "Outage from $outage_start to $outage_end. It lasted $outage_length seconds. "
			total_outage_time=$(( total_outage_time + outage_length ))
		else
			:
		fi
	else
		if $line_pass; then
			:
		else
			outage_period=true
			outage_start=$(echo "$line" | cut -d '_' -f2)
		fi
	fi
done < "$logfile"

total_duration=$(calc_time_diff $start_time $end_time)
uptime_percent=$(echo "scale=3; 100 * ($total_duration - $total_outage_time) / $total_duration" | bc)
echo "Uptime percent: $uptime_percent%"
