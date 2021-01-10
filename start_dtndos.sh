#!/bin/bash

function runScenario {
    # start core with the chosen scenario
    echo "Starting scenario: $1"
    xterm -e "core-gui --start ~/.core/configs/ion/$1/$1.imn" &
    
    # start the script visualizing the number of bundles at each node
    BV=0
    if [ -f ~/.core/configs/ion/$1/bundlewatch.sh ]
    then
        echo "Starting bundle visualization."
        sleep 1 
        xterm -e "~/.core/configs/ion/$1/bundlewatch.sh ~/.core/configs/ion/$1/" &
        BV=1
    fi
    
    # start the 'other' visualization script if there is one
    OT=0
    if [ -f ~/.core/configs/ion/${cdarray[choice]}/othervis.sh ]
    then
        echo "Starting visualization."
        sleep 1 
        xterm -hold -e "~/.core/configs/ion/$1/othervis.sh ~/.core/configs/ion/$1/" &
        OT=1
    fi
    
    # start the script visualizing the bping output
    PV=0
    if [ -f ~/.core/configs/ion/$1/pingvis.sh ]
    then
        echo "Starting bundle ping visualization."
        sleep 1
        xterm -hold -e "~/.core/configs/ion/$1/pingvis.sh ~/.core/configs/ion/$1/" &
        PV=1
    fi
    
    echo "Enter 'q' to quit the scenario."
    #wait for "q"
    while true; do
        read -e -r -p ":" symbol
        # Check that the user typed "q"
        if [[ $symbol = "q" ]]; then
           echo "Resetting CORE-daemon..."
            sudo service core-daemon restart
            echo "Done."
            echo "Stopping CORE-GUI..."
            kill $(ps -aux | grep "core.tcl" | grep -v "grep" | awk '{print $2}')
            echo "Done."
            
            if [ "$BV" -eq "1" ]
            then
                echo "Stopping bundle visualization..."
                kill $(/bin/ps -fu $USER| grep "bundlewatch" | grep -v "grep" | awk '{print $2}')
                echo "Done."
            fi
         	if [ "$OT" -eq "1" ]
            then
                echo "Stopping other visualizations..."
                kill $(/bin/ps -fu $USER| grep "othervis" | grep -v "grep" | awk '{print $2}')
                echo "Done."
            fi
            if [ "$PV" -eq "1" ]
            then
                echo "Stopping bundle ping..."
                kill $(/bin/ps -fu $USER| grep "pingvis" | grep -v "grep" | awk '{print $2}')
                echo "Done."
            fi
            if [ -f ~/.core/configs/ion/$1/cleanup.sh ]
	    then
                echo "Cleaning up scenario directory..."
                ~/.core/configs/ion/$1/cleanup.sh "$(find ~ -path "*/.core/*/$1")"
                echo "Done."
                
            fi
            clear
            break
        fi
    done
}






STATE="running"

if [ $(systemctl show -p SubState --value core-daemon) = "$STATE" ]
then
    echo -e "\e[32mcore-daemon already running! \e[39m"
else
    echo "Starting CORE-daemon..."
    sudo service core-daemon start
    echo "Done."
fi

if [ ! -d ~/.core/configs/ion ]
then 
    echo "Copying scenarios to ~/.core/config/ion ..."
    cp -r ./Scenarios/ion ~/.core/configs
fi



basedir=~/.core/configs/ion/

# Create array
cdarray=( "$basedir"/*/ )

# remove leading basedir:
cdarray=( "${cdarray[@]#"$basedir/"}" )
# remove trailing backslash and insert Exit choice
cdarray=( Exit "${cdarray[@]%/}" )

while true; do
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

echo ""
echo "===================="
echo "Available scenarios:"
echo "===================="
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
    else
        runScenario "${cdarray[choice]}"
    fi
done
