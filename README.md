# DTN-DoS

DTN-DoS is a collection of shell scripts for analyzing the effects of different variants of denial of service attacks on delay-tolerant networks.

Linux is the only supported operating system, the DTN-DoS most likely does ***not*** run on the Windows Subsystem for Linux. 

# Setup
We try to keep the setup as simple as possible. 

 1. Clone the repository using `git clone https://github.com/tobinatore/dtn-dos.git`
 2. Switch to the newly created directory.
 3. In the directory run `$ sudo ./setup.sh`. This will configure your operating system and download / install ION-DTN. 

### Remarks
#### Configuration of your OS
The script sets up a network namespace for every node in the DTN. This allows building a multi-node network on a single device instead of having a device for every node.  At the moment the number of nodes is set to 2, but we'll implement a way to specify how many nodes you want in the network in a future release.

The naming convention for the network namespaces created by the setup script is **nns-dtn-x** where **x** is the number of the future dtn node. If you - by any chance - already have a network namespace with such a name, the script will ask you whether that network namespace can be overriden. If you need it, you can refuse to override it and the script will exit.

Every network namespace created by the setup script gets assigned a veth-Interface for communicating with the other network namespaces. These interfaces each get an IP from the *10.1.1.0/24* subnet starting at *10.1.1.1* so please make sure that these IP's are available before running the setup script to avoid problems. 

Because ION-DTN needs to access an environment variable when running multiple nodes on the same machine, commands executed in a nodes network namespace ***must*** be run as root (so it's necessary to either run `$ sudo su` or `$ sudo /bin/bash` before executing commands in the network namespaces). This is because sudo resets environment variables. 

#### Download and installation of ION-DTN
The script will download version 4.0.0 of ION-DTN from Sourceforge, so make sure you're connected to the internet.

We developed and tested the script on Ubuntu 20.04. It should work on different distributions, but that's untested.

The script might seem unresponsive during the installation of ION-DTN but it is most likely not. We've decided to not display the output of the ./configure, make  and make install commands as to not clutter the terminal. Errors and warnings will still be displayed.

## Testing DoS attacks on the newly created network

*Coming soon, still in development!*
