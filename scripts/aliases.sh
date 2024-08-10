# Alias for Ranger
alias ra='ranger'

#######
# Directory Navigation
#######
alias cd="z" # Use 'z' for autojump-like directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias zz="zi" # Shortcut for frequently used command

# Create and move into a directory
function cdm() {
  mkdir -p "$1"
  cd "$1" || return
}

#######
# User Aliases
#######
alias .="nvim ."
alias v="nvim"
alias c="clear"

#######
# Enhanced ls Aliases using eza
#######
alias ls="eza --icons --git"
alias l='eza -alg --color=always --group-directories-first --git'
alias ll='eza -aliSgh --color=always --group-directories-first --icons --header --long --git'
alias lt='eza -@alT --color=always --git'
alias llt="eza --oneline --tree --icons --git-ignore"
alias lr='eza -alg --sort=modified --color=always --group-directories-first --git'

# Replace cat with bat for syntax highlighting
alias cat="bat"

#######
# Clipboard Management
#######
alias cwd="pwd | tr -d '\n' | xclip -selection clipboard"
alias copy="xclip -selection clipboard"
alias paste="xclip -selection clipboard -o"

#######
# Lazygit and Lazydocker
#######
alias lg="lazygit"
alias gg="lazygit"
alias ld="lazydocker"

#######
# Docker Utilities
#######
alias docker-compose="docker compose"

# Prune unused Docker volumes
function docker-prune-volumes() {
  docker volume rm "$(docker volume ls -q --filter dangling=true)"
}

# Kill all running Docker containers
function dockerkill() {
  docker kill "$(docker ps -q)"
}

# Find and remove Docker containers using fzf
function fdocker() {
  docker ps -a | sed 1d | fzf -q "$1" --no-sort -m --tac | awk '{ print $1 }' | xargs -r docker rm
}

#######
# Network Utilities
#######
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

#######
# Miscellaneous
#######
alias rr="rm -rf"
alias md="mkdir -p"
alias update="yay -Syu"
alias grep="rg" # Use ripgrep for faster and better searching
alias secrets="ripsecrets"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Intuitive map function for piping commands
alias map="xargs -n1"

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec ${SHELL} -l"

#######
# Dotfiles and Configuration Management
#######
alias dotfiles="cd $HOME/dotfiles"
alias zshrc="cd $HOME && nvim .zshrc"
alias nvimrc="cd $XDG_CONFIG_HOME/nvim && nvim ."
alias i3rc="cd $XDG_CONFIG_HOME/i3 && nvim config"
alias kittyrc="cd $XDG_CONFIG_HOME/kitty && nvim kitty.conf"
alias tmuxrc="cd $XDG_CONFIG_HOME/tmux && nvim tmux.conf"
alias scriptsrc="cd $HOME/.local/bin && nvim ."
alias zellijrc="cd $XDG_CONFIG_HOME/zellij && nvim config.kdl"
alias cscriptsrc="cd $XDG_CONFIG_HOME/scripts && nvim ."

#######
# Git Aliases
#######
alias gbl="git branch --format='%(refname:short)'"
alias gbr="git branch -r --format='%(refname:lstrip=3)'"
alias gswl="gbl | fzf | xargs git switch"
alias gswr="gbr | fzf | xargs git switch"

#######
# Functions
#######

# Encrypt a string using AES-256-CBC
function secretuuid() {
  echo -n "$1" | openssl enc -e -aes-256-cbc -a -salt | base64
}

# Determine size of a file or directory
function fs() {
  local arg
  if du -b /dev/null >/dev/null 2>&1; then
    arg=-sbh
  else
    arg=-sh
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@"
  else
    du $arg .[^.]* ./*
  fi
}

# Load environment variables from a file
function dotenv() {
  if [[ -f "$1" ]]; then
    set -o allexport
    source "$1"
    set +o allexport
  fi
}

# Display memory usage
function memory() {
  ps -eo size,pid,user,command --sort -size | awk '{ hr=$1/1024 ; printf("%13.2f MB ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }'
}

# Temporarily disable ZSH auto-suggestions
function anon() {
  ZSH_AUTOSUGGEST_STRATEGY=()
}

# Extract various archive formats
function extract() {
  local FILE="$1"
  if [ -f "$FILE" ]; then
    case $FILE in
    *.tar.bz2) tar xjf "$FILE" ;;
    *.tar.gz) tar xzf "$FILE" ;;
    *.bz2) bunzip2 "$FILE" ;;
    *.rar) unrar x "$FILE" ;;
    *.gz) gunzip "$FILE" ;;
    *.tar) tar xf "$FILE" ;;
    *.tbz2) tar xjf "$FILE" ;;
    *.tgz) tar xzf "$FILE" ;;
    *.zip) unzip "$FILE" ;;
    *.Z) uncompress "$FILE" ;;
    *.7z) 7z x "$FILE" ;;
    *) echo "'$FILE' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$FILE' is not a valid file"
  fi
}
