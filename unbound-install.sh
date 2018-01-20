#!/bin/bash

if [[ "$UID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

if [[ -e /etc/debian_version ]]; then
	VERSION_ID=$(cat /etc/os-release | grep "VERSION_ID")
	if [[ "$VERSION_ID" = 'VERSION_ID="7"' ]] || [[ "$VERSION_ID" = 'VERSION_ID="8"' ]] || [[ "$VERSION_ID" = 'VERSION_ID="9"' ]]; then
		OS="debian"
		elif [[ "$VERSION_ID" = 'VERSION_ID="12.04"' ]] || [[ "$VERSION_ID" = 'VERSION_ID="14.04"' ]] || [[ "$VERSION_ID" = 'VERSION_ID="16.04"' ]] || [[ "$VERSION_ID" = 'VERSION_ID="16.10"' ]] || [[ "$VERSION_ID" = 'VERSION_ID="17.04"' ]]; then
			OS="ubuntu"
			else
				echo "$VERSION_ID not supported"
				while [[ $CONTINUE != "y" && $CONTINUE != "n" ]]; do
					read -p "Continue anyway? [y/n]: " -e CONTINUE
				done
		if [[ "$CONTINUE" = "n" ]]; then
			echo "Ok, bye !"
			exit 4
		fi
	fi	
elif [[ -e /etc/centos-release || -e /etc/redhat-release || -e /etc/system-release && ! -e /etc/fedora-release ]]; then
	OS="centos"
elif [[ -e /etc/arch-release ]]; then
	OS="arch"
elif [[ -e /etc/fedora-release ]]; then
	OS="fedora"
else
	echo "Looks like you aren't running this installer on a Debian, Ubuntu, CentOS, Fedora or ArchLinux system"
	exit 4
fi

if [[ "$OS" = "debian" ]] || [[ "$OS" = "ubuntu" ]]; then
	if [[ "$OS" = "ubuntu" ]]; then
		# Remove this packages to avoid conflicts
		apt-get autoremove -y ubuntu-minimal
	fi
	# Remove this packages to avoid conflicts
	apt-get autoremove -y resolvconf
	
	# Install unbound
	apt-get update
	apt-get install -y unbound
	
	# Allow the modification of the file
	apt-get install -y e2fsprogs
fi

if [[ "$OS" = "centos" ]]; then
	# Install unbound
	yum install -y unbound
fi

if [[ "$OS" = "fedora" ]]; then
	# Install unbound
	dnf install -y unbound
fi

if [[ "$OS" = "arch" ]]; then
	# Install unbound
	pacman -Syu unbound expat
fi

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
sed -i "s|nameserver|#nameserver|" /etc/resolv.conf
# Set localhost as the DNS resolver
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
# Disallow the modification to prevent the file from being overwritten by the system
chattr +i /etc/resolv.conf

echo "The installation is done."
