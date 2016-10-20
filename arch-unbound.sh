#!/bin/bash

if [ "$UID" -ne "0" ] #User check
then
  echo "Use this script as root."
  exit 1
else
  pacman -Sy unbound expat
  wget ftp://FTP.INTERNIC.NET/domain/named.cache -O /etc/unbound/root.hints #Root servers list
  chmod 666 /etc/unbound/unbound.conf
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
qname-minimisation: yes' >> /etc/unbound/unbound.conf
  chattr -i /etc/resolv.conf #Allow the modification of the file
  sed -i 's|nameserver|#nameserver|' /etc/resolv.conf #Disable previous DNS servers
  echo "nameserver 127.0.0.1" >> /etc/resolv.conf #Set localhost as the DNS resolver
  chattr +i /etc/resolv.conf #Disallow the modification of the file
  systemctl start unbound && systemctl enable unbound #Enable named at boot and start it
  echo "The installation is done."
fi
