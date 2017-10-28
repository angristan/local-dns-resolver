#!/bin/bash

if [ "$UID" -ne "0" ]; then
	echo "Use this script as root."
	exit 1
fi

# Install unbound
dnf install -y unbound

#Configuration
sed -i 's|# hide-identity: no|hide-identity: yes|' /etc/unbound/unbound.conf
sed -i 's|# hide-identity: no|hide-identity: yes|' /etc/unbound/unbound.conf
sed -i 's|use-caps-for-id: no|use-caps-for-id: yes|' /etc/unbound/unbound.conf

# Restart unbound
systemctl restart unbound

# Disable previous DNS servers
sed -i 's|nameserver|#nameserver|' /etc/resolv.conf
# Set localhost as the DNS resolver
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
# Disallow the modification to prevent the file from being overwritten by the system
chattr +i /etc/resolv.conf

echo "The installation is done."
