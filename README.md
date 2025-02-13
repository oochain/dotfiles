# Dotfiles

My personal dotfiles and development environment setup scripts
for Ubuntu Server.

## Quick Start

```bash
# Clone then set up Ubuntu server environment
./scripts/setup_ubuntu_server.sh

# (Optional) Set up VNC server
./scripts/setup_vnc.sh
# After setup, connect to VNC on display :2
# Use Alt+Enter to open a terminal

# Install dotfiles
./scripts/update_symlinks.sh

# Set up private configurations
cp .bashrc.private.template .bashrc.private
# Edit .bashrc.private with your settings
```

## Scripts

- `scripts/setup_ubuntu_server.sh`
  Automated setup script that installs and configures development tools and
  utilities including Neovim (LazyVim), Docker, AWS tools, Python (uv),
  Terraform, and more.

- `scripts/setup_vnc.sh` (Optional)
  Sets up a VNC server with i3 window manager for remote GUI access:
  - TigerVNC server with i3 window manager
  - CaskaydiaCove Nerd Font
  - Systemd service for auto-start
  - Default resolution: 2560x1440

- `scripts/update_symlinks.sh`
  Manages dotfiles symlinks with automatic backup

## Private Configuration

Sensitive configurations (git credentials, project paths) should be stored in
`.bashrc.private` (not tracked by this repo).
