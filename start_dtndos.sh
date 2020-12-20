#!/bin/bash

echo '==================================================================='
echo '==================================================================='
echo '$$$$$$$\ $$$$$$$$\ $$\   $$\         $$$$$$$\             $$$$$$\  '
echo '$$  __$$\\__$$  __|$$$\  $$ |        $$  __$$\           $$  __$$\ '
echo '$$ |  $$ |  $$ |   $$$$\ $$ |        $$ |  $$ | $$$$$$\  $$ /  \__|'
echo '$$ |  $$ |  $$ |   $$ $$\$$ |$$$$$$\ $$ |  $$ |$$  __$$\ \$$$$$$\  '
echo '$$ |  $$ |  $$ |   $$ \$$$$ |\______|$$ |  $$ |$$ /  $$ | \____$$\ '
echo '$$ |  $$ |  $$ |   $$ |\$$$ |        $$ |  $$ |$$ |  $$ |$$\   $$ |'
echo '$$$$$$$  |  $$ |   $$ | \$$ |        $$$$$$$  |\$$$$$$  |\$$$$$$  |'
echo '\_______/   \__|   \__|  \__|        \_______/  \______/  \______/ '
echo '==================================================================='
echo '==================================================================='
echo ""

echo "Starting CORE-daemon..."
sudo service core-daemon start
echo "Done."
echo ""
echo "===================="
echo "Available scenarios:"
echo "===================="

PS3='Please enter your choice: '
options=()
select opt in "$(ls ~/.core/configs/ion)"
do
case $opt in
    "TestScenario")
     core-gui --start ~/.core/configs/ion/TestScenario/TestScenario.imn
     exit
     esac
done
