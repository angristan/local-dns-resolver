#!/bin/bash

if [[ "$UID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi
