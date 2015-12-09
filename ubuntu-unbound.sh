#!/bin/bash
if [ "$UID" -ne "0" ] #User check
then
	echo "Use this script as root."
	exit 1
else
	apt-get install unbound -y 
	service unbound stop
	unbound -c /etc/unbound/unbound.conf
	unbound-anchor -a "/var/lib/unbound/root.key"
	echo "access-control: 127.0.0.1 allow" >> /etc/unbound/unbound.conf
	echo "interface: 127.0.0.1" >> /etc/unbound/unbound.conf
	service unbound start
	chattr -i /etc/resolv.conf #Allow the modification of the file
	sed -i 's|nameserver|#nameserver|' /etc/resolv.conf #Disable previous DNS servers
	echo "nameserver 127.0.0.1" >> /etc/resolv.conf #Set localhost as the DNS resolver
	chattr +i /etc/resolv.conf #Disallow the modification of the file
	echo "The installation is done."
fi
