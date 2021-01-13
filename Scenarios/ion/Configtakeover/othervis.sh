#!/bin/bash
cd $1
while [ ! -n "$(find . -name 'node*.log' | head -1)" ]
do
echo "Waiting for nodes to start ion"
sleep 1
done

while [ 1 ]
do
	echo "Node 1:"
	cat node1.log
	echo ""
	echo "Node 2:"
	cat node2.log
	echo ""
	echo "Node 3:"
	cat node3.log
	sleep 1
	clear
done
