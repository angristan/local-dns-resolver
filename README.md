# Local DNS resolver installer for Linux

This script will install a local **Unbound** DNS resolver with **DNSSEC** support on your GNU/Linux computer/server, that will directly communicate with the root servers. This ensures speed, neutrality and no dependance on any third-party server (like your ISP's).

The resolver is "local" because Unbound will only listen on localhost and accept requests from localhost.

## Support

The script is designed to work on the following OS:

* Debian 7+
* Ubuntu 14+
* CentOS 7
* Fedora 25+
* Arch Linux

Be sure to uninstall BIND or any other DNS services on your machine before running the script, otherwise Ubound won't be able to start.

## Usage

First, download the script and make it executable:

```
wget https://raw.githubusercontent.com/Angristan/Local-DNS-resolver/master/unbound-install.sh
chmod +x unbound-install.sh
```

Then run it as root:
```
sudo ./unbound-install.sh
```

Enjoy!

## Change DNS resolver

Later, if you want to edit `/etc/resolv.conf`, run this command to allow modifications :

`chattr -i /etc/resolv.conf` (`+i` to disallow again)

## Check DNSSEC

DNSSEC should be enabled. To check if Unbound verifies DNSSEC signatures, run:

```
dig www.dnssec-failed.org | grep status
```
Which should return `status: SERVFAIL` as the signature for this domain is broken.
