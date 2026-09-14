#!/bin/bash

nohup ./uplink_test.sh > /dev/null 2>&1 &
nohup ./dns_test.sh > /dev/null 2>&1 &
echo "Tests Started"
