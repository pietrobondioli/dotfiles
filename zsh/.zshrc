##############################################################################################################
## Exports and PATH Configuration
##############################################################################################################

# Essential environment variables
export UID=$(id -u)
export GID=$(id -g)
export USER_LOG_DIR="$HOME/logs"
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/gcr/ssh"
export TERMINAL="/usr/bin/kitty"

# PATH configuration
local -a PATH_EXPORTS=(
  "$HOME/.local/bin"
  "/usr/local/bin"
  "$HOME/bin"
  "$HOME/.nvm/versions/node"
  "/usr/local/go/bin"
  "$HOME/go/bin"
  "$HOME/.dotnet/tools"
  "$HOME/.local/share/JetBrains/scripts"
  "$HOME/.config/yarn/global/node_modules/.bin"
)

PATH_RESULT="$PATH"
for path in $PATH_EXPORTS; do
  if [[ -d "$path" ]]; then 
    PATH_RESULT="$PATH_RESULT:$path"
  fi
done
export PATH="$PATH_RESULT"

# Load environment-specific configurations
source $HOME/scripts/vars
source $HOME/scripts/utils
source $HOME/scripts/aliases

##############################################################################################################
## Znap Plugin Manager Configuration
##############################################################################################################

source $HOME/.zsh/plugins/ohmyzsh/ohmyzsh/oh-my-zsh.sh

# Set up Znap if not already installed
[[ -r "$SNAP_DIR/znap.zsh" ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git $SNAP_DIR
source "$SNAP_DIR/znap.zsh"
zstyle ':znap:*' repos-dir $PLUGINS_DIR
zstyle ':znap:*:*' git-maintenance off

# Define plugins to be loaded with Znap
local -a PLUGINS=(
  "MichaelAquilina/zsh-auto-notify"
  "MichaelAquilina/zsh-you-should-use"
  "wfxr/forgit"
  "hlissner/zsh-autopair"
  "zsh-users/zsh-autosuggestions"
  "zsh-users/zsh-completions"
  "zsh-users/zsh-history-substring-search"
  "zsh-users/zsh-syntax-highlighting"
)

# Load plugins using Znap
for plugin in $PLUGINS; do
  if [[ -d "$PLUGINS_DIR/$plugin" ]]; then
    znap source $plugin || echo "Failed to load $plugin"
  else
    znap clone $plugin
  fi
done

# Load additional Oh My Zsh components and plugins via Znap
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 1
znap source ohmyzsh/ohmyzsh lib/{git,bzr,cli,clipboard,compfix,completion,correction,directories,functions,git,grep,history,key-bindings,misc,termsupport}
znap source ohmyzsh/ohmyzsh plugins/{git,fzf}

# Initialize Starship prompt
znap eval starship "starship init zsh --print-full-init"


##############################################################################################################
## Fpath Hooks and Completions
##############################################################################################################

znap fpath _fx       "source <(fx --comp zsh)"
znap fpath _gitleaks "gitleaks completion zsh"
znap fpath _kubectl  "kubectl completion zsh"
znap fpath _npm      "npm completion"
znap fpath _zellij   "zellij setup --generate-completion zsh;echo"

##############################################################################################################
## Source Files
##############################################################################################################

# Source environment-specific configurations
eval "$(zoxide init zsh)"

local -a SOURCE_FILES=(
  "$PLUGINS_DIR/hlissner/zsh-autopair/autopair.plugin.zsh"
  "$SCRIPTS/dev"
  "$SCRIPTS/fzf"
  "$SCRIPTS/git"
  "$SCRIPTS/history"
  "$SCRIPTS/mix"
  "$SCRIPTS/nav"
  "$SCRIPTS/tmux"
  "$SCRIPTS/zellij"
  "$SCRIPTS/zellij_autostart_config"
  "$SCRIPTS/zellij_tab_name_update"
  "$SCRIPTS/secrets"
)

# Load all source files
for config in $SOURCE_FILES; do
  if [[ -f "$config" ]]; then 
    source "$config"
  fi
done

zellij_tab_name_update
chpwd_functions+=(zellij_tab_name_update)

zellij_autostart_config

# Additional custom configuration or function hooks can be placed here

##############################################################################################################
## Additional User Settings
##############################################################################################################

# Set preferred editor
export EDITOR='vim'

# Display system info at terminal startup
neofetch --ascii "$(fortune | cowsay -W 40)" | lolcat

znap prompt

# NVM (Node Version Manager) setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # Load NVM
