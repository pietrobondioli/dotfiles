NODE_PATHS=$(find $HOME/.nvm/versions/node -maxdepth 1 -mindepth 1 -type d)
GO_PATH=/usr/local/go/bin:$HOME/go/bin
DOTNET_TOOLS_PATH=$HOME/.dotnet/tools
LOCAL_BIN_PATH=$HOME/.local/bin:/usr/local/bin:$HOME/bin
export PATH=$LOCAL_BIN_PATH:$NODE_PATHS:$GO_PATH:$DOTNET_TOOLS_PATH:$PATH

export USER_LOG_DIR="$HOME/logs"

log() {
  local message="$1"
  local log_file_name="${2:-default.log}"
  local log_file="$USER_LOG_DIR/$log_file_name"

  # Ensure the log directory exists
  mkdir -p "$USER_LOG_DIR"

  # Log to syslog
  logger "$message"

  # Log to the specified log file with a timestamp
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >>"$log_file"
}

source $HOME/.config/scripts/zellij_autostart_config.sh

zellij_autostart_config

neofetch --ascii "$(fortune | cowsay -W 40)" | lolcat

eval "$(zoxide init zsh)"

export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/gcr/ssh"

# Set default terminal to kitty
export TERMINAL="/usr/bin/kitty"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="xxf"

plugins=(git fzf-tab zsh-autosuggestions zsh-syntax-highlighting common-aliases command-not-found kubectl urltools encode64 themes jsontools history)

source $ZSH/oh-my-zsh.sh

# User configuration

# FZF
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Preferred editor for local and remote sessions
export EDITOR='vim'

# Source Aliases
source $HOME/.zsh_aliases

# Source Scripts
for file in ~/scripts/*; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
