#!/bin/bash

__usage="Usage: ./networkscan.sh [-n network]

By default, your own network is used. The network can be set manually.
After completion, the file 'targets' will contain the names and addresses of all targets.

Options:
-n | --network: Set the network to scan, e.g. 192.168.178
-h | --help: Print this help page"

### main ###

network=$(ifconfig | grep broadcast | cut -d ' ' -f 10 | cut -d '.' -f 1,2,3)

while [ $# -gt 0 ]; do
	case $1 in
	-n | --network )	shift
				network=$1
				;;
	-h | --help | * )	echo "$__usage"
				exit
				;;
	esac
	shift
done

echo "Scanning $network..."

# Scan the network, grep only the target names and addresses and write them to a file
nmap -sn $network.0/24 | grep ^Nmap\ scan\ report | cut -d ' ' -f 5,6 > targets

echo "Done, check 'targets' file"
