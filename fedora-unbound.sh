#!/bin/bash

if [ "$UID" -ne "0" ]; then
	echo "Use this script as root."
	exit 1
fi

# Install unbound
dnf install -y unbound

# Set conf location
unbound -c /etc/unbound/unbound.conf

# Set root key location
unbound-anchor -a "/var/lib/unbound/root.key"
	
# Configuration
mv /etc/unbound/unbound.conf /etc/unbound/unbound.conf.old
echo "server:
interface: 127.0.0.1
access-control: 127.0.0.1 allow
port: 53
do-daemonize: yes
num-threads: 2
use-caps-for-id: yes
harden-glue: yes
hide-identity: yes
hide-version: yes" > /etc/unbound/unbound.conf

# Restart unbound
systemctl restart unbound

# Disable previous DNS servers
sed -i 's|nameserver|#nameserver|' /etc/resolv.conf
# Set localhost as the DNS resolver
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
# Disallow the modification to prevent the file from being overwritten by the system
chattr +i /etc/resolv.conf

echo "The installation is done."
