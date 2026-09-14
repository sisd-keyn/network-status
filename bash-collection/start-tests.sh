#!/bin/bash

nohup ./uplink-test.sh > /dev/null 2>&1 &
nohup ./dns-test.sh > /dev/null 2>&1 &
echo "Tests Started"
