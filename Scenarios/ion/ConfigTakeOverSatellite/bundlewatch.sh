#!/bin/bash
cd $1

NUMBER_NODES=$(ls -l | grep "^d" | wc -l )


clear 
while [ ! -n "$(find . -name 'n*_bundles.log' | head -1)" ]
do
echo "Waiting for bundle counts..." 
sleep 1
clear
done

while [ 1 ]
do
for i in `seq 1 $NUMBER_NODES`
do
    if [ ! $i -eq "5" ]
    	then
        NODE="n$i"
        if [ -f "$NODE"_bundles.log ]
        then
	    echo "Bundles at node $NODE: $(head -n 1 "$NODE"_bundles.log)"
        else
           echo "Bundles at node $NODE: n/a"
        fi
    fi
done
sleep 1.5
clear
done
