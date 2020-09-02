#!/bin/bash

__usage="Usage: ./networkscan.sh [-n network] [-o output]

Default configuration:
The network to scan is your own network.
The output file is 'devices' in the working directory.

The order of the arguments doesn't matter.

Options:
-n | --network: Set the network to scan, e.g. 192.168.178
-o | --output: Set the output file
-h | --help: Print this help page"

### main ###

# Default configuration
network=$(ifconfig | grep broadcast | cut -d ' ' -f 10 | cut -d '.' -f 1,2,3)
output="devices"

while [ $# -gt 0 ]; do
	case $1 in
	-n | --network )	shift
				network=$1
				;;
	-o | --output )		shift
				output=$1
				;;
	-h | --help | * )	echo "$__usage"
				exit
				;;
	esac
	shift
done

echo "Scanning for devices on $network..."

# Scan the network, grep only the target names and addresses and write them to a file
nmap -sn $network.0/24 | grep ^Nmap\ scan\ report | cut -d ' ' -f 5,6 > $output

if [ -s $output ]; then
	echo "Done, check the '$output' file."
else
	echo "No devices found."
	rm $output
	exit
fi
