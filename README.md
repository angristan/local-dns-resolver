# Local Linux DNS resolver auto-installer
This script with install a local DNS server with DNSSEC support on you GNU/Linux computer/server, that will directly communicate with the root servers. This ensures speed, neutrality and no dependance on any third-party server (like your ISP's).

Be sure to uninstall BIND, Unbound or any other DNS services on your machine before running the script.

## Use

You must run the scripts as root.

Later, if you want to edit `/etc/resolv.conf`, run this command to allow modifications :

`chattr -i /etc/resolv.conf` (`+i` to disallow again)

### Arch - Unbound
```
wget https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/arch-unbound.sh
chmod +x arch-unbound.sh
./arch-unbound.sh
```

### Arch - PowerDNS
```
wget https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/arch-powerdns.sh
chmod +x arch-powerdns.sh
./arch-powerdns.sh
```

### Arch - BIND
```
wget https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/arch-bind.sh
chmod +x arch-bind.sh
./arch-bind.sh
```

### Debian (7,8,9) - Unbound
```
wget https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/debian-unbound.sh
chmod +x debian-unbound.sh
./debian-unbound.sh
```

### Ubuntu (14 to 17) - Unbound
```
wget https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/ubuntu-unbound.sh
chmod +x ubuntu-unbound.sh
./ubuntu-unbound.sh
```

### CentOS 7 - Unbound
```
wget https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/centos-unbound.sh
chmod +x centos-unbound.sh
./centos-unbound.sh
```

### Fedora (25 and 26, at least) - Unbound
```
wget https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/fedora-unbound.sh
chmod +x fedora-unbound.sh
./fedora-unbound.sh
```

## License

[The unlicense](https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/LICENSE)  : do whatever you want with the code.
