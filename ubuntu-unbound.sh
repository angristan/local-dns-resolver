#!/bin/bash

if [ "$UID" -ne "0" ]; then
	echo "Use this script as root."
	exit 1
fi

# Remove this packages to avoid conflicts
apt-get autoremove -y resolvconf ubuntu-minimal

# Install unbound
apt-get update
apt-get install -y unbound

# Configuration
echo 'hide-identity: yes
hide-version: yes
use-caps-for-id: yes' >> /etc/unbound/unbound.conf

# Restart unbound
service unbound restart

# Allow the modification of the file
apt-get install -y e2fsprogs
chattr -i /etc/resolv.conf
# Disable previous DNS servers
sed -i 's|nameserver|#nameserver|' /etc/resolv.conf
# Set localhost as the DNS resolver
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
# Disallow the modification to prevent the file from being overwritten by the system
chattr +i /etc/resolv.conf

echo "The installation is done."
