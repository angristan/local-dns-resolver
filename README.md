# Local Linux DNS resolver auto-installer
Unbound installer for Debian (7,8,9), Ubuntu (12 to 17), Fedora (25 and 26, at least), CentOS 7 and Arch Linux.
This script with install a local DNS server with DNSSEC support on you GNU/Linux computer/server, that will directly communicate with the root servers. This ensures speed, neutrality and no dependance on any third-party server (like your ISP's).

Be sure to uninstall BIND, Unbound or any other DNS services on your machine before running the script.

## Use
First, get the script and make it executable :
```
wget https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/unbound-install.sh
chmod +x unbound-install.sh
```
Then run it as root:
```
sudo ./unbound-install.sh
```

Later, if you want to edit `/etc/resolv.conf`, run this command to allow modifications :

`chattr -i /etc/resolv.conf` (`+i` to disallow again)


## License

[The unlicense](https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/LICENSE)  : do whatever you want with the code.
