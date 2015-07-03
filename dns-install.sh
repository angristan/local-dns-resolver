#!/bin/bash

pacman -Sy bind dnsutils
wget ftp://ftp.internic.net/domain/named.cache -O /var/named/root.hint
sed -i 's|file "/var/named/root.hint"|file "root.hint"|' /etc/named.conf
sudo chattr -i /etc/resolv.conf
sed -i 's|nameserver|#nameserver|' /etc/resolv.conf
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
sudo systemctl start named && sudo systemctl enable named
