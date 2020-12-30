#!/bin/bash

NUMBER_NODES=$(ls -l | grep "^d" | wc -l )

for (( n=1; n<=$NUMBER_NODES;n++ ))
do
    NODE="n$n"
    echo "Bundles at node $NODE: $(head -n 1 $NODE\_bundles.log)"
done
