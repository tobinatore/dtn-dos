#!/bin/bash
cd $1
while [ ! -n "$(find . -name 'node*.log' | head -1)" ]
do
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
	echo ""
	echo "Node 4:"
	cat node4.log
	echo ""
	echo "Node 5:"
	cat node5.log
	sleep 1
	clear
done
