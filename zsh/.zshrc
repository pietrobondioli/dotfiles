export ZELLIJ_AUTO_ATTACH=true
export ZELLIJ_AUTO_EXIT=true
eval "$(zellij setup --generate-auto-start zsh)"

NODE_PATHS=$(find /home/pietro/.nvm/versions/node -maxdepth 1 -mindepth 1 -type d)
GO_PATH=/usr/local/go/bin:$HOME/go/bin
export PATH=/usr/local/bin:$HOME/bin:$HOME/.local/bin:$NODE_PATHS:$GO_PATH:$PATH

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

# Ranger

function ranger {
	local IFS=$'\t\n'
	local tempfile="$(mktemp -t tmp.XXXXXX)"
	local ranger_cmd=(
		command
		ranger
		--cmd="map Q chain shell echo %d > "$tempfile"; quitall"
	)

	${ranger_cmd[@]} "$@"
	if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
		cd -- "$(cat "$tempfile")" || return
	fi
	command rm -f -- "$tempfile" 2>/dev/null
}
alias ra='ranger'

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Dirs
alias cd="z"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias zz="zi"

# User aliases
alias .="nvim ."
alias v="nvim"
alias vim="nvim"
alias c="clear"
alias ls="eza --icons --git"
alias l='eza -alg --color=always --group-directories-first --git'
alias ll='eza -aliSgh --color=always --group-directories-first --icons --header --long --git'
alias lt='eza -@alT --color=always --git'
alias llt="eza --oneline --tree --icons --git-ignore"
alias lr='eza -alg --sort=modified --color=always --group-directories-first --git'
alias cat="bat"
alias lg="lazygit"
alias cwd="pwd | tr -d '\n' | xclip -selection clipboard"
alias rr="rm -rf"
alias md="mkdir -p"
alias update="yay -Syu"
alias copy="xclip -selection clipboard"
alias paste="xclip -selection clipboard -o"

alias grep="rg"

alias zshrc="nvim ~/.zshrc && source ~/.zshrc"
alias nvimrc="nvim ~/.config/nvim"
alias i3rc="nvim ~/.config/i3/config"
alias kittyrc="nvim ~/.config/kitty/kitty.conf"

alias gbl="git branch --format='%(refname:short)'"
alias gbr="git branch -r --format='%(refname:lstrip=3)'"
alias gswl="gbl | fzf | xargs git switch"
alias gswr="gbr | fzf | xargs git switch"

# Navigation

take() {
  mkdir -p "$1"
  cd "$1"
}
cx() { cd "$@" && l; }
ffd() {
  if [ -z "$1" ]; then
    cd "$(find ~/personal ~/work ~/mack-ads ~/ -type d -maxdepth 3 -mindepth 1 -print 2>/dev/null | fzf)" && l;
  else
    cd "$(find "$1" -type d -maxdepth 3 -mindepth 1 -print 2>/dev/null | fzf)" && l;
  fi
}

neofetch

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(zoxide init zsh)"
