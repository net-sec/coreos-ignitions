#!/bin/bash

ping -c1 google.ch

if [ $? != 0 ]; then
	# need default gateway and interface as environment variable
	sudo route add default gw 192.168.43.1 enp0s3
fi
