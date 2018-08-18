#!/bin/bash

if [[ "$UID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

lsof -i udp@127.0.0.1:53 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "It looks like another software is listnening on UDP port 53:"
    echo ""
    lsof -i udp@127.0.0.1:53
    echo ""
    echo "Please disable or uninstall it before installing unbound."
    exit 1
fi

if [[ -e /etc/debian_version ]]; then
	# Detects all variants of Debian, including Ubuntu
	OS="debian"
elif [[ -e /etc/centos-release || -e /etc/redhat-release || -e /etc/system-release && ! -e /etc/fedora-release ]]; then
	OS="centos"
elif [[ -e /etc/fedora-release ]]; then
	OS="fedora"
elif [[ -e /etc/arch-release ]]; then
	OS="arch"
else
	echo "Looks like you aren't running this installer on a Debian, Ubuntu, CentOS, Fedora or Arch Linux system"
	exit 4
fi

echo ""
echo "Welcome! This script will install and configure Unbound, and set it as your default system DNS resolver."
echo ""
read -n1 -r -p "Press any key to continue..."
echo ""

if [[ "$OS" = "debian" ]]; then
	# Install Unbound
	apt-get update
	apt-get install -y unbound

	# Configuration
	echo 'hide-identity: yes
hide-version: yes
use-caps-for-id: yes
prefetch: yes' >> /etc/unbound/unbound.conf

	# Restart Unbound
	service unbound restart

	# Needed for the chattr command
	apt-get install -y e2fsprogs
fi

if [[ "$OS" = "centos" ]]; then
	# Install Unbound
	yum install -y unbound

	# Configuration
	sed -i 's|# hide-identity: no|hide-identity: yes|' /etc/unbound/unbound.conf
	sed -i 's|# hide-version: no|hide-version: yes|' /etc/unbound/unbound.conf
	sed -i 's|use-caps-for-id: no|use-caps-for-id: yes|' /etc/unbound/unbound.conf

	# Enable service at boot
	systemctl enable unbound
	# Start the service
	systemctl start unbound
fi

if [[ "$OS" = "fedora" ]]; then
	# Install Unbound
	dnf install -y unbound

	# Configuration
	sed -i 's|# hide-identity: no|hide-identity: yes|' /etc/unbound/unbound.conf
	sed -i 's|# hide-version: no|hide-version: yes|' /etc/unbound/unbound.conf
	sed -i 's|# use-caps-for-id: no|use-caps-for-id: yes|' /etc/unbound/unbound.conf

	# Enable service at boot
	systemctl enable unbound
	# Start the service
	systemctl start unbound
fi

if [[ "$OS" = "arch" ]]; then
	# Install Unbound
	pacman -Syu unbound expat

	#Permissions for the DNSSEC keys
	chown root:unbound /etc/unbound
	chmod 775 /etc/unbound

	# Get root servers list
	wget https://www.internic.net/domain/named.root -O /etc/unbound/root.hints

	# Configuration
	mv /etc/unbound/unbound.conf /etc/unbound/unbound.conf.old
	echo 'server:
	root-hints: root.hints
	auto-trust-anchor-file: trusted-key.key
	interface: 127.0.0.1
	access-control: 127.0.0.1 allow
	port: 53
	do-daemonize: yes
	num-threads: 2
	use-caps-for-id: yes
	harden-glue: yes
	hide-identity: yes
	hide-version: yes
	qname-minimisation: yes
	prefetch: yes' > /etc/unbound/unbound.conf

	# Enable service at boot
	systemctl enable unbound
	# Start the service
	systemctl start unbound
fi

# DNS Rebinding fix
PRIVATE_ADDRESSES="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 169.254.0.0/16 fd00::/8 fe80::/10 127.0.0.0/8 ::ffff:0:0/96"
echo "private-address: $PRIVATE_ADDRESSES" >> /etc/unbound/unbound.conf

# Allow the modification of the file
chattr -i /etc/resolv.conf

# Disable previous DNS servers
sed -i "s|nameserver|#nameserver|" /etc/resolv.conf
sed -i "s|search|#search|" /etc/resolv.conf

# Set localhost as the DNS resolver
echo "nameserver 127.0.0.1" >> /etc/resolv.conf

# Disallow the modification to prevent the file from being overwritten by the system.
# Use -i to enable modifications
chattr +i /etc/resolv.conf

echo "The installation is done."
