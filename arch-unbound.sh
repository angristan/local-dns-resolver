#!/bin/bash

if [ "$UID" -ne "0" ]; then
	echo "Use this script as root."
	exit 1
fi

# Install unbound
pacman -Syu unbound expat

#Permissions for the DNSSEC keys
chown root:unbound /etc/unbound
chmod 775 /etc/unbound

# Get root servers list
wget ftp://FTP.INTERNIC.NET/domain/named.cache -O /etc/unbound/root.hints

# Configuration
mv /etc/unbound/unbound.conf /etc/unbound/unbound.conf.old
echo '### Based on http://calomel.org/unbound_dns.html ###
server:
interface: 127.0.0.1
port: 53
do-ip4: yes
do-ip6: no
do-udp: yes
do-tcp: yes
do-daemonize: yes
access-control: 127.0.0.1 allow
root-hints: "/etc/unbound/root.hints"
auto-trust-anchor-file: "/etc/unbound/root.key"
hide-identity: yes
hide-version: yes
harden-glue: yes
harden-dnssec-stripped: yes
use-caps-for-id: yes
cache-min-ttl: 3600
cache-max-ttl: 86400
prefetch: yes
#num-threads: 2
rrset-cache-size: 128m
msg-cache-size: 64m
so-rcvbuf: 1m
private-address: 192.168.0.0/16
private-address: 172.16.0.0/12
private-address: 10.0.0.0/8
unwanted-reply-threshold: 10000
val-clean-additional: yes
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
