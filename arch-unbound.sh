#!/bin/bash

if [ "$UID" -ne "0" ]; then
	echo "Use this script as root."
	exit 1
fi

# Install unbound
pacman -Sy unbound expat

# Get root servers list
wget ftp://FTP.INTERNIC.NET/domain/named.cache -O /etc/unbound/root.hints #Root servers list
chmod 666 /etc/unbound/unbound.conf

# Configuration
mv /etc/unbound/unbound.conf /etc/unbound/unbound.conf.old
echo 'server:
root-hints: "/etc/unbound/root.hints"
interface: 127.0.0.1
access-control: 127.0.0.1 allow
port: 53
do-daemonize: yes
num-threads: 2
use-caps-for-id: yes
harden-glue: yes
hide-identity: yes
hide-version: yes
qname-minimisation: yes' > /etc/unbound/unbound.conf

# Enable unbound at boot and restart it
systemctl restart unbound && systemctl enable unbound

# Allow the modification of the file
chattr -i /etc/resolv.conf
# Disable previous DNS servers
sed -i 's|nameserver|#nameserver|' /etc/resolv.conf
# Set localhost as the DNS resolver
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
# Disallow the modification to prevent the file from being overwritten by the system
chattr +i /etc/resolv.conf

echo "The installation is done."
