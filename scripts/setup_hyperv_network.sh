#!/bin/bash

# Assign HOME_IP when working from home
HOME_IP="192.168.68.150"
HOME_SUBNET="192.168.68"
HOME_GATEWAY="192.168.68.1"
NETWORK_INTERFACE="eth0"

check_root() {
	if [[ "$EUID" -ne 0 ]]; then
		echo "Error: This script must be run as root. Please use sudo."
		exit 1
	fi
}

detect_network() {
	# Get current gateway IP to determine network
	GATEWAY=$(ip route | grep default | awk '{print $3}')

	# Check if we're on home network (192.168.68.x gateway)
	if [[ $GATEWAY == ${HOME_SUBNET}.* ]]; then
		echo "home"
	else
		echo "office"
	fi
}

setup_network_config() {
	local netplan_file="/etc/netplan/00-netcfg.yaml"
	local network_type=$(detect_network)

	# Backup existing config if it's the first time
	if [ ! -f "${netplan_file}.backup" ]; then
		cp "$netplan_file" "${netplan_file}.backup"
		echo "Backed up original netplan config to ${netplan_file}.backup"
	fi

	if [ "$network_type" == "home" ]; then
		echo "Detected home network, setting static IP..."
		cat >"$netplan_file" <<EOL
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - ${HOME_IP}/22
      routes:
        - to: 0.0.0.0/0
          via: ${HOME_GATEWAY}
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOL
	else
		echo "Detected office network, using DHCP..."
		cat >"$netplan_file" <<EOL
network:
  version: 2
  ethernets:
    ${NETWORK_INTERFACE}:
      dhcp4: true
EOL
	fi

	echo "Network configuration updated at $netplan_file"
}

apply_network_config() {
	netplan apply
	if [ $? -eq 0 ]; then
		echo "Netplan configuration applied successfully"
		ip addr show eth0
	else
		echo "Error applying netplan configuration"
		exit 1
	fi
}

setup_auto_detection() {
	local script_path="/usr/local/bin/network-switcher"
	local service_path="/etc/systemd/system/network-switcher.service"
	local timer_path="/etc/systemd/system/network-switcher.timer"

	# Copy the current script to a permanent location
	cp "$0" "$script_path"
	chmod +x "$script_path"

	# Create systemd service
	cat >"$service_path" <<EOL
[Unit]
Description=Network Configuration Switcher
After=network.target

[Service]
Type=oneshot
ExecStart=$script_path
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOL

	# Create systemd timer (runs every 5 minutes)
	cat >"$timer_path" <<EOL
[Unit]
Description=Run Network Configuration Switcher periodically

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
EOL

	# Enable and start the timer
	systemctl enable network-switcher.timer
	systemctl start network-switcher.timer

	echo "Automatic network detection service installed and started"
}

main() {
	check_root
	setup_network_config
	apply_network_config
	setup_auto_detection
	echo "Setup completed successfully"
	echo "Network will be automatically checked and configured every 5 minutes"
}

# If script is run directly (not through systemd service)
if [[ "$0" == *"network-switcher"* ]]; then
	# Running through systemd, just update network
	check_root
	setup_network_config
	apply_network_config
else
	# First time setup
	main
fi
