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

When you have chosen a scenario to run using the start.sh script, the core gui gets started, and the simulation runs. At the moment the setup of the scenarios has to be done by hand, but we're working on a way to automate this.

## TestScenario
The only scenario as of right now.

Please double click on every node in the core gui (n1 - n3). This will open a shell on the respective node. Run the following commands on each node:

 1. `$ cp /home/{username}/.core/configs/ion/TestScenario/{node}/ .` 
 2. `$ ionstart -I {node}.rc` or `$ ionstart -I {node}_ltp.rc`
 3. any of ION's inbuilt commands such as `bping`, `bpsource`, ... Available endpoints are `{node number}`.1 - `{node number}`.3 .

*More coming soon, still in development!*
