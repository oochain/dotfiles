#!/bin/bash
# Exit on any error
set -e

# Function to check if a command was successful
check_success() {
	if [ $? -ne 0 ]; then
		echo "Error: $1"
		exit 1
	fi
}

# Update and install necessary packages
sudo apt update && sudo apt install -y xterm i3 i3blocks tigervnc-standalone-server unzip fontconfig
check_success "Failed to install packages"

# Set VNC password only if it doesn't exist
if [ ! -f ~/.vnc/passwd ]; then
	vncpasswd
	check_success "Failed to set VNC password"
fi

# Download and install Nerd Font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/CascadiaCode.zip
unzip CascadiaCode.zip -d nerd-font-temp
mkdir -p ~/.local/share/fonts
mv nerd-font-temp/*.ttf ~/.local/share/fonts/
chmod 644 ~/.local/share/fonts/*.ttf
fc-cache -fv
rm -rf nerd-font-temp CascadiaCode.zip

# Create/Update Xresources file
cat <<EOF >~/.Xresources
! XTerm settings
xterm*faceName: CaskaydiaCoveNerdFontMono
xterm*faceSize: 14
xterm*renderFont: true
xterm*background: black
xterm*foreground: lightgray

! Better font rendering
Xft.antialias: 1
Xft.hinting: 1
Xft.rgba: rgb
Xft.hintstyle: hintslight
Xft.lcdfilter: lcddefault
EOF
check_success "Failed to create Xresources file"

# Create i3 config directory and file
mkdir -p ~/.config/i3
cat <<EOF >~/.config/i3/config
# i3 config file (v4)

# Set mod key (Mod1=<Alt>, Mod4=<Super>)
set \$mod Mod1

# Set terminal
set \$terminal xterm

# Font for window titles
font pango:CaskaydiaCoveNerdFontMono 10

# Use Mouse+\$mod to drag floating windows
floating_modifier \$mod

# Start a terminal
bindsym \$mod+Return exec \$terminal

# Kill focused window
bindsym \$mod+Shift+q kill

# Start dmenu
bindsym \$mod+d exec dmenu_run

# Change focus
bindsym \$mod+h focus left
bindsym \$mod+j focus down
bindsym \$mod+k focus up
bindsym \$mod+l focus right

# Move focused window
bindsym \$mod+Shift+h move left
bindsym \$mod+Shift+j move down
bindsym \$mod+Shift+k move up
bindsym \$mod+Shift+l move right

# Split in horizontal orientation
bindsym \$mod+b split h

# Split in vertical orientation
bindsym \$mod+v split v

# Enter fullscreen mode
bindsym \$mod+f fullscreen toggle

# Change container layout
bindsym \$mod+s layout stacking
bindsym \$mod+w layout tabbed
bindsym \$mod+e layout toggle split

# Toggle tiling / floating
bindsym \$mod+Shift+space floating toggle

# Change focus between tiling / floating windows
bindsym \$mod+space focus mode_toggle

# Focus the parent container
bindsym \$mod+a focus parent

# Define names for default workspaces
set \$ws1 "1"
set \$ws2 "2"
set \$ws3 "3"
set \$ws4 "4"

# Switch to workspace
bindsym \$mod+1 workspace number \$ws1
bindsym \$mod+2 workspace number \$ws2
bindsym \$mod+3 workspace number \$ws3
bindsym \$mod+4 workspace number \$ws4

# Move focused container to workspace
bindsym \$mod+Shift+1 move container to workspace number \$ws1
bindsym \$mod+Shift+2 move container to workspace number \$ws2
bindsym \$mod+Shift+3 move container to workspace number \$ws3
bindsym \$mod+Shift+4 move container to workspace number \$ws4

# Reload the configuration file
bindsym \$mod+Shift+c reload

# Restart i3 inplace
bindsym \$mod+Shift+r restart

# Exit i3
bindsym \$mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'"

# Resize window mode
mode "resize" {
        bindsym h resize shrink width 10 px or 10 ppt
        bindsym j resize grow height 10 px or 10 ppt
        bindsym k resize shrink height 10 px or 10 ppt
        bindsym l resize grow width 10 px or 10 ppt

        # Back to normal
        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym \$mod+r mode "default"
}
bindsym \$mod+r mode "resize"

# Window decorations
default_border pixel 2
default_floating_border pixel 2

# Start i3bar to display a workspace bar
bar {
        status_command i3blocks
        position bottom
        colors {
            background #000000
            statusline #ffffff
            separator #666666

            focused_workspace  #4c7899 #285577 #ffffff
            active_workspace   #333333 #5f676a #ffffff
            inactive_workspace #333333 #222222 #888888
            urgent_workspace   #2f343a #900000 #ffffff
        }
}

# Start terminal in workspace 1 by default
exec --no-startup-id "i3-msg 'workspace 1; exec xterm'"
EOF
check_success "Failed to create i3 config"

# Create and configure i3blocks
mkdir -p ~/.config/i3blocks
cat <<EOF >~/.config/i3blocks/config
# i3blocks config file
# Global properties
command=/usr/share/i3blocks/$BLOCK_NAME
separator_block_width=15
markup=none

# Network interface monitoring with green IP
[iface]
#instance=wlan0
color=#00FF00
interval=10

# Network speed
[bandwidth]
#instance=eth0
color=#00AAFF
interval=5

# CPU usage
[cpu_usage]
label=CPU
color=#FF5555
interval=10
min_width=CPU: 100.00%

# Memory usage
[memory]
label=MEM
color=#88FF88
interval=30

# Disk usage
[disk]
label=DISK
color=#FFAA00
interval=30

# Date Time
[time]
command=date '+%Y-%m-%d %H:%M:%S'
color=#AAAAFF
interval=5
EOF
check_success "Failed to create i3blocks config"

# Create xstartup file
mkdir -p ~/.vnc
cat <<EOF >~/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Debug logging
exec 1>/tmp/vnc-startup.log 2>&1
set -x

# Load resources
[ -r ~/.Xresources ] && xrdb ~/.Xresources

# Start i3 with logging
exec i3 -V >> /tmp/i3log 2>&1
EOF
chmod +x ~/.vnc/xstartup

# Create VNC config file
cat <<EOF >~/.vnc/config
localhost=no
geometry=2560x1440
depth=24
EOF
check_success "Failed to create VNC config"

# Create systemd service file
sudo tee /etc/systemd/system/vncserver@.service >/dev/null <<EOF
[Unit]
Description=Start TigerVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=$USER
ExecStartPre=-/bin/sh -c '/usr/bin/vncserver -kill :%i > /dev/null 2>&1 || :'
ExecStart=/usr/bin/vncserver :%i
ExecStop=/usr/bin/vncserver -kill :%i
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
check_success "Failed to create systemd service file"

# Reload systemd, enable and start VNC service
sudo systemctl daemon-reload
sudo systemctl enable vncserver@2.service
sudo systemctl stop vncserver@2.service 2>/dev/null || true
sudo systemctl start vncserver@2.service
check_success "Failed to start VNC service"

echo "VNC server setup completed successfully!"
echo "You can connect to VNC on display :2"
echo "Use Alt+Enter to open a terminal"
