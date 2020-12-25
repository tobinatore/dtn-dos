# DTN-DoS

DTN-DoS is a collection of shell scripts for analyzing the effects of different variants of denial of service attacks on delay-tolerant networks.

Linux is the only supported operating system, the DTN-DoS most likely does ***not*** run on the Windows Subsystem for Linux. 

# Setup
We try to keep the setup as simple as possible. 

 1. Clone the repository using `git clone https://github.com/tobinatore/dtn-dos.git`
 2. Switch to the newly created directory.
 3. In the directory run `$ ./setup_new.sh`. This will configure your operating system and download / install ION-DTN and CORE.
 4. Run `$ ./start.sh` this will start the scenario picker. 

### Remarks
#### setup_new.sh
This script installs two components on your system.
- CORE - A network emulation tool
- ION-DTN - A DTN implementation used by e.g. NASA
 
It also copies the included scenarios into the project directory of the CORE installation.

#### start.sh
Starts the core daemon needed for running the network simulations and prompts the user to choose a scenario. When the user has chosen a valid scenario, the scripts starts core-gui in execution mode and the simulation gets run.


#### Download and installation of CORE
The script always downloads the most recent version of CORE and installs it on your system.

If you have Docker installed, the default iptable rules will block CORE traffic.

#### Download and installation of ION-DTN
The script will download version 4.0.0 of ION-DTN from Sourceforge, so make sure you're connected to the internet.

We developed and tested the script on Ubuntu 20.04. It should work on different distributions, but that's untested.

The script might seem unresponsive during the installation of ION-DTN but it is most likely not. We've decided to not display the output of the ./configure, make  and make install commands as to not clutter the terminal. Errors and warnings will still be displayed.

## Running scenarios

When you have chosen a scenario to run using the start.sh script, the core gui gets started, and the simulation runs. The setup of the scenarios in CORE is handled by setup scripts, so you don't have to do anything besides running the start.sh script and picking a scenario.

## Overview over all included scenarios

### TestScenario
The only scenario as of right now. The following services are being automatically started when this scenario is chosen:

- bping on node 1, pinging node 3 on the 3.1 enpoint from node 1's 1.2 endpoint
- bpecho on node 3, acknowledging incoming bundles on enpoint 3.1

When double clicking on a node in the CORE-GUI, a shell with root access will open on that specific node. You can run any ION command there for further testing.
As of now, there is no script visualizing the traffic between node 1 and node 3. It's most likely that there won't be one in the near future, as this is just a basic scenario for testing. You can run `bpstats` followed by `tail ion.log` to get an overview about how many bundles were sent / received.
    
A line by line overview of the output of `bpstats`:
1. Number of bundles sourced (created) by this node. -> grouped by priority with a sum of all bundles at the end (this also applies for the following lines)
2. Number of bundles forwarded by the node.
3. Number of bundles that have been transmitted.
4. Number of bundles that have been received.
5. Number of bundles that have been delivered.
6. Number of bundles that have been custody transferred.
7. Number of bundles that have been reforwarded
8. Number of bundles that expired.

*More coming soon, still in development!*
