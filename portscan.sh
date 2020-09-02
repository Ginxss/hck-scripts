#!/bin/bash

__usage="Usage: ./portscan.sh [-t target] [-d] [-u] [-o output]

Default configuration:
The target to scan is your own IP-Address.
The output file will be 'ports' in the working directory.
Detailed and UDP Scans are disabled.

The order of the arguments doesn't matter.

Options:
-t | --target: Set the IP-Address / DNS Name to scan
-d | --detailed: Run a detailed scan on the open ports after the port scan
-u | --udp: Run a UDP scan on the top 1000 ports after the tcp scans
-o | --output: Set the output file
-h | --help: Print this help page"

### main ###

# Default configuration
target=$(ifconfig | grep broadcast | cut -d ' ' -f 10)
output="ports"
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
	-o | --output )		shift
				output=$1
				;;
	-h | --help | * )	echo "$__usage"
				exit
				;;
	esac
	shift
done

echo "Scanning for open ports on $target..."

# Scan all ports, grep the port-lines and write them to a file
nmap -p- -T4 $target | grep ^[0-9] > $output

if [ -s $output ]; then
	echo "Done - check the '$output' file."
else
	echo "No open ports found."
	rm $output
	exit
fi

if [ "$detailed" = true ]; then
	echo -e "\nRunning detailed scan on open ports..."

	# Make a comma-separated list of ports
	pts=$(cut -d '/' -f 1 $output | tr '\n' ',')

	echo -e "\n\n-----TCP PORT DETAILS-----\n" >> $output

	# Run a -A scan on that list and append the result to the output
	nmap -A -p$pts -T4 $target | tail -n +5 >> $output

	echo "Done - check the '$output' file."
fi

if [ "$udp" = true ]; then
	echo -e "\nScanning for open ports on UDP (top 1000)..."

	echo -e "\n\n-----UDP PORTS-----\n" >> $output

	# Scan the top 1000 UDP ports, grep the port-lines and append them to the output
	nmap -sU -T4 $target | grep ^[0-9] >> $output

	echo "Done - check the '$output' file."
fi
