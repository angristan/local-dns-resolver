# Local Linux DNS resolver auto-installer
This script with install a local DNS server on you GNU/Linux computer, and will directly communicate with the root servers. This ensure speed, neutrality and no dependance on any third-party server.

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

### Debian - Unbound
```
wget https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/debian-unbound.sh
chmod +x debian-unbound.sh
./debian-unbound.sh
```

### Ubuntu - Unbound
```
wget https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/ubuntu-unbound.sh
chmod +x ubuntu-unbound.sh
./ubuntu-unbound.sh
```

### CentOS - Unbound
```
wget https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/centos-unbound.sh
chmod +x centos-unbound.sh
./centos-unbound.sh
```

Note : it does not work on CentOS 6. Any PR is welcome.

### Fedora - Unbound
```
wget https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/fedora-unbound.sh
chmod +x fedora-unbound.sh
./fedora-unbound.sh
```

## License

[The unlicense](https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/LICENSE)  : do whatever you want with the code.
