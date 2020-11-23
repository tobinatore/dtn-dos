#!/bin/bash
echo "How many nodes does your DTN have?"
read NUM_NODES
for ((node=1;node<=$NUM_NODES;node++));
do
echo -e "\e[31mDeleting network namespace 'nns-dtn-$node'..."
ip netns delete nns-dtn-$node
echo -e "\e[31mDeleting directory 'node$node'..."
rm -r node$node
done
echo -e "\e[31mDeleting directory 'nodes'..."
rm -r nodes

echo -e "\e[31mDeleting bridge..."
ip link set br1 down
sudo ip link del br1
echo -e  "\e[31mDONE"

