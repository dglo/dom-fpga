#!/bin/bash 

#
# get current fpga type
#
if [[ ! -f fpga_type ]] ;  then
	echo "no fpga_type file..."
	exit 1
fi
cat fpga_type

