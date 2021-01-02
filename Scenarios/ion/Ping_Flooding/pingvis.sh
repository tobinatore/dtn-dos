#!/bin/bash

cd $1

clear 
while [ ! -n "$(find . -name 'ping.log' | head -1)" ]
do
echo "Waiting for ping to start up..." 
sleep 1
clear
done

while [ 1 ]
do
    echo "$(cat ping.log)"
    sleep 1
    clear
done
