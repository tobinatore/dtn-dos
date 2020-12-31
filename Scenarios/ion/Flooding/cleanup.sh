#!/bin/bash
cd $1

find . -name "n*_bundles.log" | xargs rm -f 
rm -f ./ping.log

