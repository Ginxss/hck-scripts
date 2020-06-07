#!/bin/bash

__usage="Usage: ./portscan.sh [-t ip] [-d] [-u]

By default, your own IP-Address is used. The IP can be set manually.
After the port scan, the file 'ports' will contain all open ports on the target machine.
After the detailed scan, the file 'port_details' will contain the scan results for the open ports.
After the UDP scan, the file 'ports_udp' will contain all open UDP ports.

Options:
-t | --target: Set the IP-Address to scan.
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

if [ -s ports ]; then
	echo "Done - check the 'ports' file"
else
	echo "No open ports found"
	rm ports
	exit
fi

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
