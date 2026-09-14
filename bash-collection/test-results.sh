#!/bin/bash

flag_d=false
flag_u=false

# If no flags are passed, default to all of them
if [ $# -eq 0 ]; then
    flag_u=true
    flag_d=true
fi

# Parse options
while getopts "du" opt; do
    case $opt in
        d) flag_d=true ;;
        u) flag_u=true ;;
        ?) echo "Usage: $0 [-d] [-u]"; exit 1 ;;
    esac
done

start_date=$(date +%F)
echo "Network testing results for $start_date"
echo ""

if $flag_u; then
    echo "Results from uplink_test.sh"
    pass=$(grep "PASS" current-logs/uplink-ping-*.log | wc -l)
    fail=$(grep "FAIL" current-logs/uplink-ping-*.log | wc -l)
    sum=$(($pass + $fail))
    percent=$(echo "scale=3; 100 * $pass / $sum" | bc)
    echo "Number of passes: $pass"
    echo "Number of fails: $fail"
    echo "Uptime percentage: $percent %"
    echo ""
fi

if $flag_d; then
    echo "Results from dns_test.sh"
    pass=$(grep "PASS" current-logs/dns-test-*.log | wc -l)
    fail=$(grep "FAIL" current-logs/dns-test-*.log | wc -l)
    sum=$(($pass + $fail))
    percent=$(echo "scale=3; 100 * $pass / $sum" | bc)
    echo "Number of passes: $pass"
    echo "Number of fails: $fail"
    echo "Uptime percentage: $percent %"
    echo ""
fi

echo "End of testing results."
