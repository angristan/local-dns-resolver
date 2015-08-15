#!/bin/bash

if [ "$UID" -ne "0" ] #User check
then
echo -e "Use this script as root."
exit
else
pacman -Sy unbound expat
wget ftp://FTP.INTERNIC.NET/domain/named.cache -O /etc/unbound/root.hints #Root servers list
chmod 666 /etc/unbound/unbound.conf
echo "  root-hints: "/etc/unbound/root.hints"" >> /etc/unbound/unbound.conf
echo "  interface: 127.0.0.1" >> /etc/unbound/unbound.conf
chmod 644 /etc/unbound/unbound.conf
chattr -i /etc/resolv.conf #Allow the modification of the file
sed -i 's|nameserver|#nameserver|' /etc/resolv.conf #Disable previous DNS servers
echo "nameserver 127.0.0.1" >> /etc/resolv.conf #Set localhost as the DNS resolver
chattr +i /etc/resolv.conf #Disallow the modification of the file
systemctl start unbound && systemctl enable unbound #Enable named at boot and start it
fi
