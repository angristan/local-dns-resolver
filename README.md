# ArchLinux-DNS-server
This script with install a local DNS server on you Arch Linux (or Arch-based) computer, and will directly communicate with the root servers securely (using DNSSEC).


## Use

You must choose one of the two scripts. You *CAN'T* use them both. 

They both must be run as root.

### Unbound
`wget https://raw.githubusercontent.com/Angristan/ArchLinux-DNS-server/master/unbound-install.sh`

`chmod +x unbound-install.sh`

`./unbound-install.sh`

### BIND
`wget https://raw.githubusercontent.com/Angristan/ArchLinux-DNS-server/master/bind-install.sh`

`chmod +x bind-install.sh`

`./bind-install.sh`

## Contact / Feedback 

http://angristan.fr/contact/ or open an [issue](https://github.com/Angristan/ArchLinux-DNS-server/issues)

## License

[The unlicense](https://github.com/Angristan/ArchLinux-DNS-server/blob/master/LICENSE) (public domain)
