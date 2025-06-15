#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Backup directory with timestamp
backup_dir="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Function to create symlink
create_symlink() {
	local source=$1
	local target=$2

	# Check if source exists
	if [ ! -e "$source" ]; then
		echo -e "${RED}Error: Source file $source does not exist${NC}"
		return 1
	fi

	# Check if target already exists
	if [ -e "$target" ]; then
		# Create backup directory if it doesn't exist
		if [ ! -d "$backup_dir" ]; then
			mkdir -p "$backup_dir"
			echo -e "${YELLOW}Created backup directory: $backup_dir${NC}"
		fi

		# Backup existing file/directory
		mv "$target" "$backup_dir/"
		echo -e "${YELLOW}Backed up existing $target to $backup_dir/${NC}"
	fi

	# Create symlink
	ln -sf "$source" "$target"
	echo -e "${GREEN}Created symlink: $target -> $source${NC}"
}

# List of files to symlink (source -> target)
create_symlink "$HOME/dotfiles/.bashrc" "$HOME/.bashrc"
if [ ! -e "$HOME/.bashrc.private" ]; then
	echo -e "${YELLOW}.bashrc.private does not exist in home directory${NC}"
	if [ -e "$HOME/dotfiles/.bashrc.private.template" ]; then
		cp "$HOME/dotfiles/.bashrc.private.template" "$HOME/.bashrc.private"
		echo -e "${GREEN}Copied template to $HOME/.bashrc.private${NC}"
	else
		echo -e "${RED}Error: Template file $HOME/dotfiles/.bashrc.private.template does not exist${NC}"
	fi
else
	echo -e "${GREEN}.bashrc.private already exists in home directory${NC}"
fi
create_symlink "$HOME/dotfiles/.tmux.conf" "$HOME/.tmux.conf"
create_symlink "$HOME/dotfiles/.config/nvim" "$HOME/.config/nvim"
create_symlink "$HOME/dotfiles/.config/starship.toml" "$HOME/.config/starship.toml"

echo -e "${GREEN}Completed! Backup directory: $backup_dir${NC}"
