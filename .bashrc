# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

export PATH="$HOME/.local/bin:$PATH"
# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
*) ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	#alias dir='dir --color=auto'
	#alias vdir='vdir --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

# Ensure PROJECT_PATHS is defined even if private config is missing
declare -A PROJECT_PATHS

# Make the example paths more generic in the comment
# workon example incase .bashrc.private lost
# declare -A PROJECT_PATHS=(
#     ["example"]="/path/to/example"
#     ["hl"]="/github/homelab"
# )

# Load all .bashrc.xxx configurations and merge PROJECT_PATHS
for config_file in ~/.bashrc.*; do
	if [[ -f "$config_file" ]]; then
		# Clear temp array before sourcing
		unset PROJECT_PATHS_TEMP
		source "$config_file"

		# Merge PROJECT_PATHS_TEMP if it exists
		if [[ ${#PROJECT_PATHS_TEMP[@]} -gt 0 ]]; then
			for key in "${!PROJECT_PATHS_TEMP[@]}"; do
				PROJECT_PATHS["$key"]="${PROJECT_PATHS_TEMP[$key]}"
			done
		fi
	fi
done

# work on project(optional)
wo() {
	[[ "$VIRTUAL_ENV" != "" ]] && deactivate
	local target_dir=${PROJECT_PATHS[$1]}

	if [[ -z "$1" ]]; then
		echo "Available projects:"
		for key in "${!PROJECT_PATHS[@]}"; do
			echo "  $key -> ${PROJECT_PATHS[$key]}"
		done
		return 0
	fi

	if [[ -z "$target_dir" && -d "/work/$1" ]]; then
		target_dir="/work/$1"
	fi

	if [[ -n "$target_dir" ]]; then
		cd "$target_dir"
	else
		echo "No specific path defined for '$1'. Available projects:"
		for key in "${!PROJECT_PATHS[@]}"; do
			echo "  $key -> ${PROJECT_PATHS[$key]}"
		done
		return 1
	fi

	[[ ! -d ".venv" ]] && echo "Warning: Virtual environment not found in $(pwd)" && echo "Please run 'uv venv' to create one"
	source ".venv/bin/activate" 2>/dev/null || echo "Failed to activate virtual environment"
	echo "Current directory: $(pwd)"

	export PS1='(\[\033[01;32m\]'"$1"'\[\033[00m\]) \[\033[01;34m\]\W\[\033[00m\]$(__git_ps1 " (\[\033[01;31m\]%s\[\033[00m\])")\$ '
}

# update upgrade then prune
uup() {
	sudo apt update
	sudo apt full-upgrade --fix-missing -y
	sudo apt reinstall ubuntu-release-upgrader-core
	sudo apt autoremove -y
}

export_pythonpath() {
	export PYTHONPATH=$(pwd)
	echo "Update PYTHONPATH to: $PYTHONPATH"
}

export_display_ssh() {
	export DISPLAY=localhost:10.0
	echo "Update DISPLAY to SSH: $DISPLAY"
}

export_display_vnc() {
	export DISPLAY=:2
	echo "Update DISPLAY to VNC: $DISPLAY"
}

# used for clear nvim cache
clear_nvim() {
	rm ~/.local/state/nvim/swap/*
}

# Function to source .bashrc in all tmux panes
source_bashrc() {
	local orig_dir=$(pwd)
	cd && source ~/.bashrc
	[ -d "$orig_dir" ] && cd "$orig_dir"

	if [ -n "$TMUX" ]; then
		local current_pane=$(tmux display-message -p '#P')
		tmux list-panes -F '#P' | while read pane; do
			if [ "$pane" != "$current_pane" ]; then
				# Get the current directory of the target pane
				local target_dir=$(tmux display-message -t $pane -p '#{pane_current_path}')
				# Execute the sourcing command
				tmux send-keys -t $pane "cd && source ~/.bashrc && cd '$target_dir'" Enter
			fi
		done
	fi
}

# tmux shortcuts
t() {
	if [[ -z "$1" ]]; then
		tmux ls
	else
		if tmux has-session -t "$1"; then
			tmux attach -t "$1"
		else
			tmux new -s "$1"
		fi
	fi

}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

source ~/git-subrepo/.rc

# Generated by luarocks (for nvim)
. "$HOME/.cargo/env"
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
export PATH="$PATH:$HOME/.local/share/nvim/lazy-rocks/hererocks/bin"

# Generated by uv
eval "$($HOME/.local/bin/uv generate-shell-completion bash)"
eval "$($HOME/.local/bin/uvx --generate-shell-completion bash)"

eval "$(starship init bash)"
