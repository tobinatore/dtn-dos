#!/bin/bash

while [ 1 ]
do
    bplist | grep -Eo '[0-9]{1,6}' | tail -1 > `dirname $SESSION_FILENAME`/"n$1"_bundles.log
    sleep 1
done
