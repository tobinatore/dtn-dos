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
NUMBER_OF_NODES=0
# Getting the number of nodes the user wants to have.

echo "======================="
echo "Configuring environment"
echo "======================="
echo " "
while [ $NUMBER_OF_NODES -lt 3 ] || [ $NUMBER_OF_NODES -gt 10 ]
do
    echo "Please enter the number of nodes your DTN should have (3..10):"
    read NUMBER_OF_NODES
done

# Checking whether the needed network namespaces exist.
# If they do not yet exist they get created.
echo "Checking if network namespaces for the DTN exist..."
for ((val=1;val<=$NUMBER_OF_NODES;val++));
do
    if [[ $NETWORK_NAMESPACES != *"nns-dtn-$val"* ]];
    then
        echo -e "\e[33mNetwork namespace 'nns-dtn-$val' not found!"
        echo -e "\e[37mCreating network namespace \e[1m'nns-dtn-$val'\e[0m."
        ip netns add nns-dtn-$val
        echo -e "\e[32mDone."
    else
        echo -e "\e[33mWARNING! There exists a network namespace called 'nns-dtn-$val'."
        echo -e "\e[33mProceeding will overwrite it with a new network namespace!"
        echo -e "\e[37mDo you wish to proceed?"
        select yn in "Yes" "No"; do
            case $yn in
               Yes ) ip netns delete nns-dtn-$val; ip netns add nns-dtn-$val; break;;
               No ) exit;;
            esac
        done
        echo -e "Created the network namespace \e[1m'nns-dtn-$val'\e[0m."
    fi
done

echo -e "\e[39m "
# Creating the virtual bridge which works as a switch, directing traffic between
# the network namespaces.
ip link add name br1 type bridge
ip link set br1 up 
# Creating the virtual Ethernet interfaces needed for linking the
# network namespaces to the bridge.
for ((node=1;node<=$NUMBER_OF_NODES;node++));
do
    echo "Creating the veth interface linking node $node and bridge"
    ip link add node-veth$node type veth peer name bridge-veth$node
    echo "Assigning the interface to the namespaces..."
    ip link set node-veth$node netns nns-dtn-$node
    ip link set bridge-veth$node master br1
done
echo -e "\e[32mSuccessfully created and assigned the needed interfaces!"
echo -e "\e[39m "
echo -e "\e[32mDone."
echo -e "\e[39m "

# Configuring the newly created interfaces in their respective namespaces.
echo "Configuring the veth interfaces..."
echo "Setting IP-Addresses..."
ip addr add 10.1.1.0/24 brd + dev br1
echo -e "IP-Address of \e[1m'br1'\e[0m set to \e[1;4m10.1.1.0\e[0m"

for ((node=1;node<=$NUMBER_OF_NODES;node++));
do
    ip netns exec nns-dtn-$node ip addr add 10.1.1.$node/24 dev node-veth$node
    echo -e "IP-Address of \e[1m'node$node-veth'\e[0m set to \e[1;4m10.1.1.$node\e[0m"
done
echo -e "\e[32mDone."
echo -e "\e[39mBringing the interfaces up..."
for ((node=1;node<=$NUMBER_OF_NODES;node++));
do
    ip netns exec nns-dtn-$node ip link set dev node-veth$node up
    ip link set bridge-veth$node up
done

echo -e "\e[32mDone."

echo -e "\e[39m "

# Testing connection
echo "Testing connections..."
for ((node=1;node<$NUMBER_OF_NODES;node++));
do
    for ((peer=$node+1;peer<=$NUMBER_OF_NODES;peer++));
    do
        echo -e "Testing connection nns-dtn-$node -> nns-dtn-$peer..."
        ip netns exec nns-dtn-$node ping -c 1 -I node-veth$node 10.1.1.$peer
        if [ $? -eq 0 ]
        then
            echo -e "\e[32mConnection works!"
            echo -e "\e[39m "
        else echo -e "\e[31mPing failed!"
           	exit
        fi
    done
echo -e "\e[39m "
echo "------------------------------------------- "

done
echo -e "\e[39m "

# Setting the ION_NODE_LIST_DIR environment variable for every 
# new bash instance in the NNS by adding it to the .bashrc file.
# -> All commands which need this variable need to be run in a 
# root shell instantiated with "sudo su".
mkdir nodes
if grep -q "ION_NODE_LIST_DIR" ~/.bashrc
then
	echo "ION_NODE_LIST_DIR environment variable already set."
else
	echo "Setting ION_NODE_LIST_DIR environment variable..."
	#sudo echo "export ION_NODE_LIST_DIR=$PWD/nodes" >> ~/.bashrc
fi

echo -e "\e[39mConfiguration of environment completed!"
echo -e "\e[39m "


echo "=============="
echo "Setting up DTN"
echo "=============="
echo " "

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
    apt install build-essential -y 1> /dev/null
    echo "Downloading build 4.0.0 of ION-DTN... "
    wget https://sourceforge.net/projects/ion-dtn/files/ion-4.0.0.tar.gz/download
    echo "Extracting files... "
    tar xzf download
    rm download
    echo "Changing directories -> ion-4.0.0/... "
    cd ion-open-source-4.0.0
    echo "Installing... "
    ./configure 1> /dev/null
    make 1> /dev/null
    make install 1> /dev/null
    ldconfig 1> /dev/null
    echo -e "\e[32mFinished installing ION-DTN."
    cd ..
fi

echo -e "\e[39m "
echo "=============================="
echo "Generating configuration files"
echo "=============================="
echo " "

echo "Changing directories -> dtn-dos/..."

# Creating a subdirectory for each node,
# which contains the configuration files.
for ((node=1;node<=$NUMBER_OF_NODES;node++));
do
 echo "Creating directory 'node$node'..."
    mkdir node$node
    echo "Changing directory -> node$node/..."
    cd node$node
    HOST_FILE="host$node.rc"
    echo "Creating $HOST_FILE..."
    touch $HOST_FILE
    echo "## begin ionadmin" > $HOST_FILE
    echo "1 $node 'node$node.ionconfig'" >> $HOST_FILE
    echo " " >> $HOST_FILE
    echo "s" >> $HOST_FILE
    echo " " >> $HOST_FILE
    for ((first=1;first<=$NUMBER_OF_NODES;first++));
    do
        for ((second=1;second<=$NUMBER_OF_NODES;second++));
        do
            echo "a contact +1 +3600 $first $second 100000" >> $HOST_FILE
        done
    done
    echo " " >> $HOST_FILE

    for ((first=1;first<=$NUMBER_OF_NODES;first++));
    do
        for ((second=1;second<=$NUMBER_OF_NODES;second++));
        do
            echo "a range +1 +3600 $first $second 1" >> $HOST_FILE
        done
    done
    echo " " >> $HOST_FILE

    echo "m production 1000000" >> $HOST_FILE
    echo "m consumption 1000000" >> $HOST_FILE
    echo "## end ionadmin" >> $HOST_FILE
    echo " " >> $HOST_FILE
    echo "## begin ionsecadmin" >> $HOST_FILE
    echo "1" >> $HOST_FILE
    echo "## end ionsecadmin" >> $HOST_FILE
    echo " " >> $HOST_FILE
    echo "## begin ltpadmin" >> $HOST_FILE
    echo "1 32" >> $HOST_FILE
    echo " " >> $HOST_FILE
    for((span=1;span<=$NUMBER_OF_NODES;span++));
    do
        echo "a span $span 32 32 1400 10000 1 'udplso 10.1.1.$span:1113' 300" >> $HOST_FILE
    done
    echo " " >> $HOST_FILE
    echo "s 'udplsi 10.1.1.$node:1113'" >> $HOST_FILE
    echo "## end ltpadmin" >> $HOST_FILE
    echo " " >> $HOST_FILE

    echo "## begin bpadmin" >> $HOST_FILE
    echo "1" >> $HOST_FILE
    echo "a scheme ipn 'ipnfw' 'ipnadminep'" >> $HOST_FILE
    echo " " >> $HOST_FILE
    echo "a endpoint ipn:$node.0 q" >> $HOST_FILE
    echo "a endpoint ipn:$node.1 q" >> $HOST_FILE
    echo "a endpoint ipn:$node.2 q" >> $HOST_FILE
    echo " " >> $HOST_FILE
    echo "a protocol ltp 1400 100" >> $HOST_FILE
    echo " " >> $HOST_FILE
    echo "a induct ltp $node ltpcli" >> $HOST_FILE
    for ((outs=1;outs<=$NUMBER_OF_NODES;outs++));
    do
        echo "a outduct ltp $outs ltpclo" >> $HOST_FILE
    done
    echo " " >> $HOST_FILE
    echo "s" >> $HOST_FILE
    echo "## end bpadmin" >> $HOST_FILE
    echo " " >> $HOST_FILE
    echo "## begin ipnadmin" >> $HOST_FILE
    for ((plan=1;plan<=$NUMBER_OF_NODES;plan++))
    do
        echo "a plan $plan ltp/$plan" >> $HOST_FILE
    done
    echo "## end ipnadmin" >> $HOST_FILE
    CONFIG_FILE=node$node.ionconfig
    echo "Creating configuration file $CONFIG_FILE..."
    touch $CONFIG_FILE
    echo "sdrName node$node" > $CONFIG_FILE
    echo "wmKey $node" >> $CONFIG_FILE
    SCRIPT_FILE=start_node_$node.sh
    echo -e "#!/bin/bash\n" > $SCRIPT_FILE
    echo -e "ionstart -I host$node.rc" >> $SCRIPT_FILE
    echo -e "" >> $SCRIPT_FILE
    chmod 777 -R ../node$node/
    gnome-terminal -e "ionstart -I host$node.rc" &
    #exec ./start_node_$node.sh &
    cd ..
    sleep 3s
done
echo ""

echo -e "\e[32;1mFinished setup!\e[0m"


