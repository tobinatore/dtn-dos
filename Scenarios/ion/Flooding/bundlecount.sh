#!/bin/bash

# Does not work yet
while [ 1 ]
do
    echo "Test" >> testlog.log
    bplist > "$1"_bundles.log
    sleep 1
done
