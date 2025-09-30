#!/bin/bash

set -e # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Logging functions
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if we have sudo privileges or can get them
if ! sudo -v &>/dev/null; then
	log_error "This script requires sudo privileges. Please enter your password when prompted."
	exit 1
fi

# Keep sudo alive throughout the script
while true; do
	sudo -n true
	sleep 60
	kill -0 "$$" || exit
done 2>/dev/null &

# Prevent running as root directly
if [ "$USER" = "root" ]; then
	log_error "Do not run this script as the root user directly. Run as a normal user."
	exit 1
fi

####################
# Install...
####################

# Package groups
CORE_PACKAGES="build-essential libreadline-dev libssl-dev"
UTIL_PACKAGES="curl wget unzip unrar jq tree \
    fail2ban network-manager \
    fonts-noto-cjk language-pack-zh-hans xfonts-wqy \
    moreutils pwgen sqlite3 xclip nethogs"
PYTHON_PACKAGES="clang python3-pip python3-venv pipx"
NVIM_PACKAGES="fd-find lua5.1 luarocks fish fzf"

echo "Installing system packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y $CORE_PACKAGES $UTIL_PACKAGES $PYTHON_PACKAGES $NVIM_PACKAGES

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Install tree-sitter-cli for nvim
if ! command_exists npm; then
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
	# Source nvm without relying on environment variables
	source ~/.nvm/nvm.sh
	nvm install 22
fi
npm install -g tree-sitter-cli

# Install LazyGit
if ! command_exists lazygit; then
	echo "Installing LazyGit..."
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	sudo install lazygit /usr/local/bin
else
	echo "LazyGit already installed"
fi

# Install Ripgrep
if ! command_exists rg; then
	echo "Installing Ripgrep..."
	curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep_14.1.0-1_amd64.deb
	sudo dpkg -i ripgrep_14.1.0-1_amd64.deb
else
	echo "Ripgrep already installed"
fi

# Install ruff
curl -LsSf https://astral.sh/ruff/install.sh | sh

# Install/Update Neovim to v0.11.4
echo "Installing/Updating Neovim to v0.11.4..."
sudo rm -rf /opt/nvim /opt/nvim-linux-x86_64 /usr/local/bin/nvim # Remove old versions
curl -LO https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.appimage
sudo mv nvim-linux-x86_64.appimage /opt/nvim.appimage
sudo chmod +x /opt/nvim.appimage
sudo ln -s /opt/nvim.appimage /usr/local/bin/nvim
echo "Neovim v0.11.4 installed."

# Install Terraform
if ! command_exists terraform; then
	echo "Installing Terraform..."
	sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
	wget -O- https://apt.releases.hashicorp.com/gpg |
		gpg --dearmor |
		sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
		sudo tee /etc/apt/sources.list.d/hashicorp.list
	sudo apt update && sudo apt-get install -y terraform
else
	echo "Terraform already installed"
fi

# Install Packer
if ! command_exists packer; then
	echo "Installing Packer..."
	if [ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]; then
		wget -O- https://apt.releases.hashicorp.com/gpg |
			gpg --dearmor |
			sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
	fi
	if [ ! -f /etc/apt/sources.list.d/hashicorp.list ]; then
		echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
		https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
			sudo tee /etc/apt/sources.list.d/hashicorp.list
	fi
	sudo apt-get update && sudo apt-get install -y packer
else
	echo "Packer already installed"
fi

# Install Google Chrome (can run on a VNC Ubuntu server without a GUI)
if ! command_exists google-chrome; then
	echo "Installing Google Chrome..."
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo apt install -y ./google-chrome-stable_current_amd64.deb || {
		sudo apt-get install -f -y
		sudo apt install -y ./google-chrome-stable_current_amd64.deb
	}
	rm google-chrome-stable_current_amd64.deb
else
	echo "Google Chrome already installed"
fi

# Chrome needs additional Nerd Fonts as fallback fonts for symbols and CJK characters
setup_chrome_fonts() {
	echo "Configuring Chrome font support..."

	# Create fontconfig directory
	mkdir -p ~/.config/fontconfig/conf.d/

	# Create font configuration for proper fallback
	cat <<EOF >~/.config/fontconfig/conf.d/10-chrome-nerd-fonts.conf
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <!-- Configure font fallback for Chrome -->
    <alias>
        <family>sans-serif</family>
        <prefer>
            <family>Noto Sans CJK SC</family>
            <family>CaskaydiaCoveNerdFont</family>
            <family>Noto Color Emoji</family>
            <family>DejaVu Sans</family>
        </prefer>
    </alias>
    
    <alias>
        <family>serif</family>
        <prefer>
            <family>Noto Serif CJK SC</family>
            <family>CaskaydiaCoveNerdFont</family>
            <family>Noto Color Emoji</family>
            <family>DejaVu Serif</family>
        </prefer>
    </alias>
    
    <alias>
        <family>monospace</family>
        <prefer>
            <family>CaskaydiaCoveNerdFont</family>
            <family>Noto Sans Mono CJK SC</family>
            <family>DejaVu Sans Mono</family>
        </prefer>
    </alias>
    
    <!-- Ensure symbols render properly -->
    <match target="pattern">
        <test name="family">
            <string>sans-serif</string>
        </test>
        <edit name="family" mode="prepend" binding="weak">
            <string>CaskaydiaCoveNerdFont</string>
        </edit>
    </match>
</fontconfig>
EOF

	# Install additional font packages for better coverage
	sudo apt install -y fonts-noto-color-emoji fonts-liberation2 fonts-dejavu

	# Refresh font cache
	fc-cache -fv

	# Create Chrome font preferences (this sets defaults for new profiles)
	CHROME_PREFS_DIR="$HOME/.config/google-chrome/Default"
	if [ -d "$CHROME_PREFS_DIR" ]; then
		# Backup existing preferences
		[ -f "$CHROME_PREFS_DIR/Preferences" ] && cp "$CHROME_PREFS_DIR/Preferences" "$CHROME_PREFS_DIR/Preferences.backup"

		# Set font preferences in Chrome
		python3 -c "
import json
import os

prefs_file = '$CHROME_PREFS_DIR/Preferences'
prefs = {}

if os.path.exists(prefs_file):
    with open(prefs_file, 'r') as f:
        try:
            prefs = json.load(f)
        except json.JSONDecodeError:
            prefs = {}

# Set font preferences
if 'webkit' not in prefs:
    prefs['webkit'] = {}
if 'webprefs' not in prefs['webkit']:
    prefs['webkit']['webprefs'] = {}

font_prefs = {
    'fonts': {
        'fixed': {
            'Zyyy': 'CaskaydiaCoveNerdFont',
            'Hans': 'Noto Sans Mono CJK SC'
        },
        'sansserif': {
            'Zyyy': 'CaskaydiaCoveNerdFont',
            'Hans': 'Noto Sans CJK SC'
        },
        'serif': {
            'Zyyy': 'CaskaydiaCoveNerdFont', 
            'Hans': 'Noto Serif CJK SC'
        },
        'standard': {
            'Zyyy': 'CaskaydiaCoveNerdFont',
            'Hans': 'Noto Sans CJK SC'
        }
    }
}

prefs['webkit']['webprefs'].update(font_prefs)

with open(prefs_file, 'w') as f:
    json.dump(prefs, f, indent=2)
" 2>/dev/null || echo "Chrome preferences will be set on first run"
	fi

	echo "Chrome font configuration completed."
	echo "Please restart Chrome for changes to take effect."
}

setup_chrome_fonts

# Install Docker
if ! command -v docker &>/dev/null; then
	echo "Installing Docker..."
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh get-docker.sh
else
	echo "Docker already installed"
fi
sudo usermod -aG docker $USER

# For Amazon ECR Credential Helper
if ! command_exists docker-credential-ecr-login; then
	echo "Installing Amazon ECR Credential Helper..."
	sudo apt install -y amazon-ecr-credential-helper
else
	echo "ECR Credential Helper already installed"
fi
mkdir -p ~/.docker
echo '{ "credsStore": "ecr-login" }' >~/.docker/config.json

echo "Setting up AWS tools..."
# Install AWS CLI v2
if command -v aws &>/dev/null; then
	AWS_VERSION=$(aws --version 2>&1 | cut -d/ -f2 | cut -d' ' -f1)
	echo "AWS CLI v$AWS_VERSION is already installed"
	echo "Updating AWS CLI..."
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip -q awscliv2.zip
	sudo ./aws/install --update
else
	echo "Installing AWS CLI v2..."
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip -q awscliv2.zip
	sudo ./aws/install
fi
rm -fr aws/ awscliv2.zip

# For AWS SSM Plugin
if ! command_exists session-manager-plugin; then
	echo "Installing AWS SSM Plugin..."
	curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
	sudo dpkg -i session-manager-plugin.deb
else
	echo "AWS SSM Plugin already installed"
fi

# Install uv (Python package manager)
if ! command_exists uv; then
	echo "Installing uv..."
	curl -LsSf https://astral.sh/uv/install.sh | sh
else
	echo "Updating uv..."
	uv self update
fi

# Install rust + cargo (starship dependency)
curl https://sh.rustup.rs -sSf | sh -s -- -y

# Install starship
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install git-subrepo
rm -rf ~/git-subrepo
git clone https://github.com/ingydotnet/git-subrepo ~/git-subrepo

# Add paths to ~/.bashrc if they don't exist
declare -a paths=(
	'source ~/git-subrepo/.rc'
	'. "$HOME/.cargo/env"'
	'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"'
	'export PATH="$PATH:$HOME/.local/share/nvim/lazy-rocks/hererocks/bin"'
	'eval "$($HOME/.local/bin/uv generate-shell-completion bash)"'
	'eval "$($HOME/.local/bin/uvx --generate-shell-completion bash)"'
	'eval "$(starship init bash)"'
)

for path in "${paths[@]}"; do
	grep -qxF "$path" ~/.bashrc || echo "$path" >>~/.bashrc
done

# Install TPM for tmux (only if not already installed)
TPM_PATH="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_PATH" ]; then
	echo "Installing TPM for tmux..."
	mkdir -p "$TPM_PATH"
	git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
	# Only source if tmux.conf exists and tmux is running
	if [ -f "$HOME/.tmux.conf" ] && tmux list-sessions &>/dev/null; then
		tmux source-file "$HOME/.tmux.conf"
	fi
else
	echo "TPM for tmux already installed."
fi

echo -e "${GREEN}Ubuntu setup completed successfully!${NC}"
