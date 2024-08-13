#####################################################################################
## Important exports
export LISTMAX=10000
export SCRIPTS="$HOME/scripts"
export DOTFILES="$HOME/dotfiles"
export ZSH="$HOME/.zsh/plugins/ohmyzsh/ohmyzsh"
export ZSH_CUSTOM="$HOME/.zsh/plugins/ohmyzsh/ohmyzsh/custom/"
export PLUGINS_DIR="$HOME/.zsh/plugins"
export BROWSER="firefox"
export SNAP_DIR="$PLUGINS_DIR/znap"
export GPG_TTY="$(tty)"
export CASE_SENSITIVE="false"
export HIST_STAMPS="yyyy-mm-dd"
export DISABLE_UNTRACKED_FILES_DIRTY="true"
export ENABLE_CORRECTION="true"
export HYPHEN_INSENSITIVE="true"
export KEYTIMEOUT=1000
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_COLLATE=C
export MANPATH="/usr/local/man:$MANPATH"

#####################################################################################
## ZSH_PLUGINS
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor line regexp)
export ZSH_THEME="xxc"

#####################################################################################
## Auto notify plugin
export AUTO_NOTIFY_BODY="Completed in %elapseds - Exit code %exit_code"
export AUTO_NOTIFY_EXPIRE_TIME=5000
export AUTO_NOTIFY_IGNORE=("vim" "ssh" "st" "fzf" "nvim" "mvim" "neovim" "zshrc" "zellij")
export AUTO_NOTIFY_THRESHOLD=10000
export AUTO_NOTIFY_TITLE="%command - Finished"

#####################################################################################
## Cat + Bat + Less + Man
export BAT_PAGER="less"
export DELTA_PAGER="less -R"
export EDITOR="nvim"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export PAGER=""

#####################################################################################
## other utils stuff
export PNPM_HOME="$HOME/.local/share/pnpm"
