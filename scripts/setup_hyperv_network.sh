#!/bin/bash

check_root() {
	if [[ "$EUID" -ne 0 ]]; then
		echo "Error: This script must be run as root.Please use sudo."
		exit 1
	fi
}

check_root

# Ensure an IP address is provided
if [ -z "$1" ]; then
	echo "Usage: $0 <STATIC_IP> (CIDR /24 is assumed if not provided)"
	exit 1
fi

STATIC_IP="$1"

# Append /24 if CIDR is missing
if [[ ! "$STATIC_IP" =~ /[0-9]+$ ]]; then
	STATIC_IP="$STATIC_IP/24"
fi

# Extract network part and set gateway automatically
IFS='.' read -r i1 i2 i3 i4 <<<"$(echo $STATIC_IP | cut -d'/' -f1)"
GATEWAY="$i1.$i2.$i3.1"

sudo rm -f /etc/netplan/*.yaml

sudo tee /etc/netplan/00-netcfg.yaml >/dev/null <<EOL
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - $STATIC_IP
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
      routes:
        - to: default
          via: $GATEWAY

EOL
sudo chmod 600 /etc/netplan/00-netcfg.yaml

sudo netplan apply
