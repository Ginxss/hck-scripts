#!/bin/bash

__usage="Usage: ./portscan.sh [-t ip] [-d] [-u]

Options:
-t | --target: Set the IP-Address to scan. If no target is specified, your own IP-Address is used.
-d | --detailed: Run a detailed scan on the open ports after the port scan.
-u | --udp: Run a UDP scan on the top 1000 ports after the tcp scans.
-h | --help: Print this help page."

### main ###

# Get own IP from ifconfig
target=$(ifconfig | grep broadcast | cut -d ' ' -f 10)
detailed=false
udp=false

while [ $# -gt 0 ]; do
	case $1 in
	-t | --target )		shift
				target=$1
				;;
	-d | --detailed )	detailed=true
				;;
	-u | --udp )		udp=true
				;;
	-h | --help | * )	echo "$__usage"
				exit
				;;
	esac
	shift
done

echo "Scanning for open ports on $target..."

# Scan all ports, grep the port-lines and write them to a file
nmap -p- -T4 $target | grep ^[0-9] > ports

echo "Done - check the 'ports' file"

if [ "$detailed" = true ]; then
	echo "Running detailed scan on open ports..."

	# Make a comma-separated list of ports
	pts=$(cut -d '/' -f 1 ports | tr '\n' ',')
	# Run a -A scan on that list
	nmap -A -T4 -p$pts $target > port_details

	echo "Done - check the 'port_details' file"
fi

if [ "$udp" = true ]; then
	echo "Scanning for open ports on UDP (top 1000)..."

	nmap -sU -T4 $target | grep ^[0-9] > ports_udp

	echo "Done - check the 'ports_udp' file"
fi
