#!/bin/bash

if [[ "$UID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

if [[ -e /etc/debian_version ]]; then
	OS="debian"
elif [[ -e /etc/centos-release || -e /etc/redhat-release || -e /etc/system-release && ! -e /etc/fedora-release ]]; then
	OS="centos"
elif [[ -e /etc/fedora-release ]]; then
	OS="fedora"
elif [[ -e /etc/arch-release ]]; then
	OS="arch"
else
	echo "Looks like you aren't running this installer on a Debian, Ubuntu, CentOS, Fedora or ArchLinux system"
	exit 4
fi

if [[ "$OS" = "debian" ]]; then
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

# Permissions for the DNSSEC keys
chown root:unbound /etc/unbound
chmod 775 /etc/unbound

# Get root servers list
wget ftp://FTP.INTERNIC.NET/domain/named.cache -O /etc/unbound/root.hints

# Get trust anchor
unbound-anchor -a /etc/unbound/root.key

# Configuration
mv /etc/unbound/unbound.conf /etc/unbound/unbound.conf.old
echo '### Validating, recursive and caching DNS Server ###
### Based on http://calomel.org/unbound_dns.html ###

server:

# Specify the interfaces to answer queries from by ip-address.  The default
# is to listen to localhost (127.0.0.1 and ::1). Specify 0.0.0.0 and ::0 to
# bind to all available interfaces. Specify every interface[@port] on a new
# "interface:" labeled line. The listen interfaces are not changed on
# reload, only on restart.
interface: 127.0.0.1

# Port to answer queries from.
port: 53

# Enable IPv4, "yes" or "no".
do-ip4: yes

# Enable IPv6, "yes" or "no".
do-ip6: no

# Enable UDP, "yes" or "no".
do-udp: yes

# Enable TCP, "yes" or "no". If TCP is not needed, Unbound is actually
# quicker to resolve as the functions related to TCP checks are not done.
# NOTE: you may need tcp enabled to get the DNSSEC results from *.edu domains
# due to their size.
do-tcp: yes

# Enable or disable whether the unbound server forks into the
# background as a daemon. Set the value to no when unbound runs
# as systemd service. Default is yes.
do-daemonize: yes

# Control which client ips are allowed to make (recursive) queries to this
# server. Specify classless netblocks with /size and action. By default
# everything is refused, except for localhost. Choose deny (drop message),
# refuse (polite error reply), allow (recursive ok), allow_snoop (recursive
# and nonrecursive ok).
access-control: 127.0.0.1 allow

# Read  the  root  hints from this file. Default is nothing, using built in
# hints for the IN class. The file has the format of  zone files,  with  root
# nameserver  names  and  addresses  only. The default may become outdated,
# when servers change, therefore it is good practice to use a root-hints
# file. Get one from ftp://FTP.INTERNIC.NET/domain/named.cache
root-hints: "/etc/unbound/root.hints"

# File with trusted keys, kept up to date using RFC5011 probes, initial file
# like trust-anchor-file, then it stores metadata. Use several entries, one
# per domain name, to track multiple zones. If you use forward-zone below to
# query the Google DNS servers you MUST comment out this option or all DNS
# queries will fail.
# auto-trust-anchor-file: "/etc/unbound/root.key"
auto-trust-anchor-file: "/etc/unbound/root.key"

# If enabled id.server and hostname.bind queries are refused.
hide-identity: yes

# If enabled version.server and version.bind queries are refused.
hide-version: yes

# Will trust glue only if it is within the servers authority.
# Harden against out of zone rrsets, to avoid spoofing attempts. 
# Hardening queries multiple name servers for the same data to make
# spoofing significantly harder and does not mandate dnssec.
harden-glue: yes

# Require DNSSEC data for trust-anchored zones, if such data is absent, the
# zone becomes  bogus.  Harden against receiving dnssec-stripped data. If you
# turn it off, failing to validate dnskey data for a trustanchor will trigger
# insecure mode for that zone (like without a trustanchor). Default on,
# which insists on dnssec data for trust-anchored zones.
harden-dnssec-stripped: yes

# Use 0x20-encoded random bits in the query to foil spoof attempts.
# http://tools.ietf.org/html/draft-vixie-dnsext-dns0x20-00
# While upper and lower case letters are allowed in domain names, no significance
# is attached to the case. That is, two names with the same spelling but
# different case are to be treated as if identical. This means calomel.org is the
# same as CaLoMeL.Org which is the same as CALOMEL.ORG.
use-caps-for-id: yes

# The time to live (TTL) value lower bound, in seconds. Default 0.
# If more than an hour could easily give trouble due to stale data.
cache-min-ttl: 3600

# The time to live (TTL) value cap for RRsets and messages in the
# cache. Items are not cached for longer. In seconds.
cache-max-ttl: 86400

# Perform prefetching of close to expired message cache entries. If a client
# requests the dns lookup and the TTL of the cached hostname is going to
# expire in less than 10% of its TTL, unbound will (1st) return the ip of the
# host to the client and (2nd) pre-fetch the dns request from the remote dns
# server. This method has been shown to increase the amount of cached hits by
# local clients by 10% on average.
prefetch: yes

# Number of threads to create. 1 disables threading. This should equal the number
# of CPU cores in the machine.https://raw.githubusercontent.com/cezar97/Local-DNS-resolver/master/unbound-install.sh
num-threads: 1

# Increase the memory size of the cache. Use roughly twice as much rrset cache
# memory as you use msg cache memory. Due to malloc overhead, the total memory
# usage is likely to rise to double (or 2.5x) the total cache memory. The test
# box has 4gig of ram so 256meg for rrset allows a lot of room for cacheed objects.
rrset-cache-size: 128m
msg-cache-size: 64m

# Buffer size for UDP port 53 incoming (SO_RCVBUF socket option). This sets
# the kernel buffer larger so that no messages are lost in spikes in the traffic.
so-rcvbuf: 1m

# Enforce privacy of these addresses. Strips them away from answers. It may
# cause DNSSEC validation to additionally mark it as bogus. Protects against
# "DNS Rebinding" (uses browser as network proxy). Only "private-domain" and
# "local-data" names are allowed to have these private addresses. No default.
private-address: 192.168.0.0/16
private-address: 172.16.0.0/12
private-address: 10.0.0.0/8

# If nonzero, unwanted replies are not only reported in statistics, but also
# a running total is kept per thread. If it reaches the threshold, a warning
# is printed and a defensive action is taken, the cache is cleared to flush
# potential poison out of it. A suggested value is 10000000, the default is
# 0 (turned off). We think 10K is a good value.
unwanted-reply-threshold: 10000

# Should additional section of secure message also be kept clean of unsecure
# data. Useful to shield the users of this validator from potential bogus
# data in the additional section. All unsigned data in the additional section
# is removed from secure messages.
val-clean-additional: yes

# Send minimum amount of information to upstream servers to
# enhance privacy. Only sent minimum required labels of the QNAME
# and set QTYPE to NS when possible. Best effort approach; full
# QNAME and original QTYPE will be sent when upstream replies with
# a RCODE other than NOERROR, except when receiving NXDOMAIN from
# a DNSSEC signed zone. Default is off.
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
