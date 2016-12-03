#!/bin/bash

if [ "$UID" -ne "0" ]; then
   echo "Use this script as root."
   exit 1
fi

# Install bind
pacman -Syu bind

# Getting root servers list
wget ftp://ftp.internic.net/domain/named.cache -O /var/named/root.hint
sed -i 's|file "/var/named/root.hint"|file "root.hint"|' /etc/named.conf

# Enable bind at boot and restart it
systemctl restart named && systemctl enable named

# Disable previous DNS servers
sed -i 's|nameserver|#nameserver|' /etc/resolv.conf
# Set localhost as the DNS resolver
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
# Disallow the modification to prevent the file from being overwritten by the system
chattr +i /etc/resolv.conf

echo "The installation is done."
