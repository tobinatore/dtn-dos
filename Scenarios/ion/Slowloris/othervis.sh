#!/bin/bash

clear 
while [ ! -f $1/loris.log ]
do
echo "Waiting for slowloris to start up..." 
sleep 1
clear
done

echo "Slowloris attack started!"
echo "You should see the connection deteriorate."
