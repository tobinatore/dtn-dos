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

basedir=~/.core/configs/ion/

# Create array
cdarray=( "$basedir"/*/ )

# remove leading basedir:
cdarray=( "${cdarray[@]#"$basedir/"}" )
# remove trailing backslash and insert Exit choice
cdarray=( Exit "${cdarray[@]%/}" )

# check that at least one directory's in there:
if ((${#cdarray[@]}<=1)); then
    echo 'No subdirectories found. Exiting.\n'
    exit 0
fi

# Display the menu:
printf 'Please choose from the following. Enter 0 to exit.\n'
for i in "${!cdarray[@]}"; do
    printf '   %d %s\n' "$i" "${cdarray[i]}"
done
echo ""

#wait for user input
while true; do
    read -e -r -p 'Your choice: ' choice
    # Check that user's choice is a valid number
    if [[ $choice = +([[:digit:]]) ]]; then
        # Force the number to be interpreted in radix 10
        ((choice=10#$choice))
        # Check that choice is a valid choice
        ((choice<${#cdarray[@]})) && break
    fi
    echo 'Invalid choice, please start again.\n'
done

# checking if user chose exit and stopping the core daemon should that be the case.
if ((choice==0)); then
    echo 'Stopping CORE-daemon...\n'
    sudo service core-daemon stop
    echo 'Done.'
    echo 'Exiting.'
    exit 0
fi

# start core with the chosen scenario
echo "Starting scenario: ${cdarray[choice]}"
core-gui --start ~/.core/configs/ion/${cdarray[choice]}/${cdarray[choice]}.imn 

