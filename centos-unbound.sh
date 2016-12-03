#!/bin/bash

if [ "$UID" -ne "0" ]; then
	echo "Use this script as root."
	exit 1
fi

# Install unbound
yum install unbound -y

# Set conf location
unbound -c /etc/unbound/unbound.conf

# Set root key location
unbound-anchor -a "/var/lib/unbound/root.key"
	
# Configuration
echo "interface: 127.0.0.1
access-control: 127.0.0.1 allow
port: 53
do-daemonize: yes
hide-identity: yes
hide-version: yes" >> /etc/unbound/unbound.conf

# Restart unbound
service unbound restart

# Allow the modification of the file
chattr -i /etc/resolv.conf
# Disable previous DNS servers
sed -i 's|nameserver|#nameserver|' /etc/resolv.conf
# Set localhost as the DNS resolver
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
# Disallow the modification to prevent the file from being overwritten by the system
chattr +i /etc/resolv.conf

echo "The installation is done."
