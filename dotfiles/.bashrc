# ~/.bashrc - Managed by dottie
# This file is synced across all machines

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend

# Check window size after each command
shopt -s checkwinsize

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -10'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Docker aliases
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'

# Kubernetes aliases
alias k='kubectl'

# Azure CLI aliases
alias azl='az login'
alias azs='az account show'

# netclaw
alias netclaw='~/.netclaw/bin/netclaw'

# jcode - default to Claude Haiku
alias jcode='jcode -m claude-haiku-4-5-20251001'

# .NET aliases
alias dn='dotnet'
alias dnr='dotnet run'
alias dnb='dotnet build'
alias dnt='dotnet test'

# Path additions
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# .NET SDK
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools"

# Source bashrc.d scripts
if [ -d "$HOME/.bashrc.d" ]; then
    for file in "$HOME/.bashrc.d"/*.sh; do
        [ -f "$file" ] && . "$file"
    done
fi

# Rust (cargo)
if [ -d "$HOME/.cargo/bin" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Go
if [ -d "/usr/local/go/bin" ]; then
    export PATH="$PATH:/usr/local/go/bin"
    export PATH="$PATH:$HOME/go/bin"
fi

export JCODE_NO_AUTO_UPDATE=1 

# jcode built-in SearXNG web search (search.ants.zone, self-hosted on the NAS)
export JCODE_SEARXNG_URL="https://mcpuser:E7DRdzKJCQeAmgIaY_3an9aSySjqGnMJ@search.ants.zone"

# Editor
export EDITOR=code
export VISUAL=code

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Azure CLI completion
if [ -f /etc/bash_completion.d/azure-cli ]; then
    . /etc/bash_completion.d/azure-cli
fi

# kubectl completion
if command -v kubectl &> /dev/null; then
    source <(kubectl completion bash)
    complete -F __start_kubectl k
fi

# helm completion
if command -v helm &> /dev/null; then
    source <(helm completion bash)
fi

# gh completion
if command -v gh &> /dev/null; then
    eval "$(gh completion -s bash)"
fi

# nvm (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Initialize Starship prompt (must be at the end)
# Use green color scheme to distinguish bash from PowerShell (blue)
export STARSHIP_CONFIG="$HOME/.config/starship-bash.toml"
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi
# netclaw shell setup
. '/home/ryan/.netclaw/env'
