#!/bin/bash

check_root() {
	if [[ "$EUID" -ne 0 ]]; then
		echo "Error: This script must be run as root.Please use sudo."
		exit 1
	fi
}

check_root

network_type=$1

sudo rm -f /etc/netplan/*.yaml

if [[ $network_type == "home" ]]; then
	sudo tee /etc/netplan/01-home-netcfg.yaml >/dev/null <<EOL
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.68.150/24
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
      routes:
        - to: default
          via: 192.168.68.1
EOL
	sudo chmod 600 /etc/netplan/01-home-netcfg.yaml
elif [[ $network_type == "office" ]]; then
	sudo tee /etc/netplan/00-netcfg.yaml >/dev/null <<EOL
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
EOL
	sudo chmod 600 /etc/netplan/00-netcfg.yaml
	else:
	echo "Error: Invalid argument. Can only accept 'home' or 'office'."
	exit 1
fi

sudo netplan apply
