#!/bin/bash

# Checking if the script is run with elevated priviledges.
# This is needed for - amongst other things - mounting new network namespaces.
if [ "$EUID" -ne 0 ]
then echo -e "\e[31mPlease run as root as the script may need to mount network namespaces."
echo -e "\e[39m "
exit
fi

# Printing the setup text
echo '---------------------------------------------------'
echo '             _____      _                          '
echo '            /  ___|    | |                         '
echo '            \ `--.  ___| |_ _   _ ____             '
echo '             `--. \/ _ \ __| | | |  _ \            '
echo '            /\__/ /  __/ |_| |_| | |_) |           '
echo '            \____/ \___|\__|\__,_| .__/            '
echo '                                 | |               '
echo '                                 |_|               '
echo '---------------------------------------------------'

# Variables
NETWORK_NAMESPACES=$(ip netns list)
EXISTING_INTERFACES=$(ip link list)

# Checking whether the needed network namespaces exist.
# If they do not yet exist they get created.
echo "Checking if network namespaces for the DTN (nns-dtn-1 and nns-dtn-2) exist..."
if [[ $NETWORK_NAMESPACES != *"nns-dtn-1"* ]];
then
    echo -e "\e[33mCould not find network namespace 'nns-dtn-1'!"
    echo -e "\e[37mCreating network namespace \e[1m'nns-dtn-1'\e[0m."
    ip netns add nns-dtn-1
    echo -e "\e[32mDone."
else
    echo -e "\e[33mWARNING! There exists a network namespace called 'nns-dtn-1'."
    echo -e "\e[33mProceeding will overwrite it with a new network namespace!"
    echo -e "\e[37mDo you wish to proceed?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) ip netns delete nns-dtn-1; ip netns add nns-dtn-1; break;;
            No ) exit;;
        esac
    done
   echo -e "Created the network namespace \e[1m'nns-dtn-1'\e[0m."
fi
echo " "
if [[ $NETWORK_NAMESPACES != *"nns-dtn-2"* ]];
then
    echo -e "\e[33mCould not find network namespace 'nns-dtn-2'!"
    echo -e "\e[37mCreating network namespace \e[1m'nns-dtn-2'\e[0m."
    ip netns add nns-dtn-2
    echo -e "\e[32mDone." 
else
    echo -e "\e[33mWARNING! There exists a network namespace called 'nns-dtn-2'."
    echo -e "\e[33mProceeding will overwrite it with a new network namespace!"
    echo -e "\e[37mDo you wish to proceed?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) ip netns delete nns-dtn-2; ip netns add nns-dtn-2; break;;
            No ) exit;;
        esac
    done
   echo -e "Created the network namespace \e[1m'nns-dtn-2'\e[0m."
fi

echo -e "\e[39m "

# Creating the virtual Ethernet interfaces needed for linking the
# network namespaces. 
echo "Creating the veth interfaces for the network namespaces..."
ip link add node1-veth type veth peer name node2-veth
echo -e "\e[32mSuccessfully created the needed interfaces!"
echo -e "\e[39m "
echo "Assigning the interfaces to their respective namespaces..."
ip link set node1-veth netns nns-dtn-1
ip link set node2-veth netns nns-dtn-2
echo -e "\e[32mDone."

echo -e "\e[39m "

# Configuring the newly created interfaces in their respecive namespaces.
echo "Configuring the veth interfaces..."
echo "Setting IP-Addresses..."
ip netns exec nns-dtn-1 ip addr add 10.1.1.1/24 dev node1-veth
echo -e "IP-Address of \e[1m'node1-veth'\e[0m set to \e[1;4m10.1.1.1\e[0m"
ip netns exec nns-dtn-2 ip addr add 10.1.1.2/24 dev node2-veth
echo -e "IP-Address of \e[1m'node2-veth'\e[0m set to \e[1;4m10.1.1.2\e[0m"
echo -e "\e[32mDone."
echo -e "\e[39mBringing the interfaces up..."
ip netns exec nns-dtn-1 ip link set dev node1-veth up
ip netns exec nns-dtn-2 ip link set dev node2-veth up
echo -e "\e[32mDone."

echo -e "\e[39m "

# Testing connection
echo "Testing connection nns-dtn-1 -> nns-dtn-2..."
ip netns exec nns-dtn-1 ping -c 1 -I node1-veth 10.1.1.2
if [ $? -eq 0 ]
then 
    echo -e "\e[32mConnection works!"
else echo -e "\e[31mPing failed!"
	exit
fi

echo -e "\e[39m "

# Setting the ION_NODE_LIST_DIR environment variable for every 
# new bash instance in the NNS by adding it to the .bashrc file.
# -> All commands which need this variable need to be run in a 
# root shell instantiated with "sudo su".
mkdir nodes
sudo ip -all netns exec bash -c "echo export ION_NODE_LIST_DIR=$PWD/nodes >> ~/.bashrc"

echo -e "\e[39mConfiguration of environment completed!"
echo -e "\e[39m "



echo "Checking for installed DTN..." 
ionstart -I test.rc 1> /dev/null
if [ $? -eq 0 ]
then    echo -e "\e[32mION installed!" 
else
    echo -e "\e[31mION not installed!"
    echo -e "\e[39mInstalling ION-DTN."

    echo "Do you wish to run sudo apt update first?" 
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) sudo apt update; break;;
            No ) echo "Skipping sudo apt update.";break;;
        esac
    done
    echo "Installing package build-essential..."
    sudo apt install build-essential -y 1> /dev/null
    echo "Downloading build 4.0.0 of ION-DTN... "
    wget https://sourceforge.net/projects/ion-dtn/files/ion-4.0.0.tar.gz/download
    echo "Extracting files... "
    tar xzf download
    rm download
    echo "Changing directories -> ion-4.0.0... "
    cd ion-open-source-4.0.0
    echo "Installing... "
    ./configure 1> /dev/null
    make 1> /dev/null
    sudo make install 1> /dev/null
    sudo ldconfig 1> /dev/null
    echo -e "\e[32mFinished installing ION-DTN."
fi
echo ""
echo -e "\e[32;1mFinished setup!\e[0m"
