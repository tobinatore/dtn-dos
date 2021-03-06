#!/bin/bash

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


# Checking if system is Ubuntu 20.04.1 LTS
if [ ! "$(lsb_release -d | awk -F"\t" '{print $2}')" == "Ubuntu 20.04.1 LTS" ]
then
	echo -e "\e[31mYou're not on Ubuntu 20.0.4.1 LTS!"
	echo -e "\e[39mExiting."
	exit 1
fi


echo "======================="
echo "Getting needed packages"
echo "======================="
echo " "
sudo apt install -y ncat xterm


echo "==============="
echo "Setting up CORE"
echo "==============="
echo " "
if [ -x "$(command -v core-gui)" ]; then
    echo -e "\e[32mCORE already installed! Skipping installation."
    echo -e "\e[39m"
else
    echo -e "\e[93mCORE not installed! Proceeding with installation."
    echo -e "\e[39m"
    if [ -x "$(command -v docker)" ]; then
        echo -e "\e[93mWARNING: Docker is installed, the default iptable rules will block CORE traffic!"
        echo -e "\e[39m"
    fi
    echo "Fetching git repository at https://github.com/coreemu/core.git..."
    git clone https://github.com/coreemu/core.git
    echo "Installing dependencies..."
    sudo apt-get install -y autotools-dev autoconf
    echo "Changing directories -> /core..."
    cd core
    echo "Installing CORE locally..."
    #./bootstrap.sh
    #./configure
    #make
    #sudo make install
    xterm -e "./install.sh"
    echo "Changing directories -> dtn-dos ..."
    cd ..
    echo "Starting CORE so default configs get generated..."
    core-gui &
    sleep 5
    kill $(/bin/ps -fu $USER| grep "core-gui" | grep -v "grep" | awk '{print $2}')
    echo -e "\e[32mDone."
    echo -e "\e[39m"

fi 

echo "==============="
echo "Setting up DTN"
echo "==============="
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
    ./configure
    make
    sudo make install
    sudo ldconfig
    echo -e "\e[32mFinished installing ION-DTN."
    cd ..
fi

echo -e "\e[39m "

echo -e "\e[32;1mFinished setup!\e[0m"
echo -e "\e[1mYou can now run start.sh to run a scenario. A full list of scenarios can be found in the 'Scenarios' directory."


