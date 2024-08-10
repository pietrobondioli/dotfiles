#!/bin/bash

# Set log file name
log_file_name="fzf.log"

#############################################################################################################################
## FZF Configuration
#############################################################################################################################

# Default FZF commands
export FZF_DEFAULT_COMMAND="fd --type f --strip-cwd-prefix"
export FZF_ALT_C_COMMAND="bfs -color -mindepth 1 -exclude \( -name .git \) -type d -printf '%P\n' 2>/dev/null"
export FZF_ALT_C_OPTS="--preview 'tree -C {}'"
export FZF_CTRL_T_COMMAND="bfs -color -mindepth 1 -exclude \( -name .git \) -printf '%P\n' 2>/dev/null"
export FORGIT_FZF_DEFAULT_OPTS="--ansi --exact --border --cycle --reverse --height '80%' --preview-window right,50%"

# FZF default options
export FZF_DEFAULT_OPTS="
--ansi
--bind 'ctrl-/:toggle-preview'
--bind 'ctrl-y:execute-silent(printf {} | cut -f 2- | pbcopy)'
--border
$FZF_COLORS
--height 95%
--info=inline
--layout=reverse
--preview '~/dotfiles/bin/lessfilter.sh {}'
--preview-window right,75%
-i
"

# FZF options for CTRL-R
export FZF_CTRL_R_OPTS="
--preview 'echo {}' --preview-window up:3:hidden:wrap
--bind 'ctrl-/:toggle-preview'
--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
--color header:italic
--header 'Press CTRL-Y to copy command into clipboard'"

#############################################################################################################################
## FZF Functions
#############################################################################################################################

# FZF Completion Run with Custom Preview
function _fzf_comprun() {
  local command="$1"
  shift
  case "$command" in
  cd)
    log "Running FZF with directory preview using tree for command: cd" "$log_file_name"
    fzf "$@" --preview 'tree -C {} | head -200'
    ;;
  *)
    log "Running FZF with custom preview script for command: $command" "$log_file_name"
    fzf "$@" --preview '~/dotfiles/bin/lessfilter.sh {}'
    ;;
  esac
}

# Custom FZF Git Integration
function _fzf_git_fzf() {
  log "Running FZF Git Integration" "$log_file_name"
  fzf-tmux \
    --ansi \
    --bind 'ctrl-/:toggle-preview' \
    --bind 'ctrl-y:execute-silent(printf {} | cut -f 2- | pbcopy)' \
    --bind='ctrl-/:change-preview-window(down,50%,border-top|hidden|)' \
    $FZF_COLORS --color=dark \
    --height '95%' \
    --info=inline \
    -l "90%" \
    --layout=reverse --multi --height=90% --min-height=30 \
    --preview '~/dotfiles/bin/lessfilter.sh {}' \
    --preview-window 'right,75%' \
    -i \
    -p90%,90% \
    "$@"
}

# Change Directory Using FZF
function fcd() {
  log "Changing directory using FZF" "$log_file_name"
  cd "$(find . -type d -print | fzf)"
}

# Evaluate Command Using FZF
function fzf-eval() {
  log "Evaluating command using FZF" "$log_file_name"
  echo | fzf -q "$*" --preview-window=up:99% --preview="eval {q}"
}

# View Files Using FZF
function view() {
  log "Viewing files using FZF" "$log_file_name"
  fd --type f --strip-cwd-prefix | fzf
}

# Change Directory Using FZF with Hidden Files
function cdf() {
  log "Changing directory to hidden directories using FZF" "$log_file_name"
  local dir
  dir="$(fd --type directory --hidden --exclude .git | fzf)"
  cd "$PWD/$dir"
}

# Run NPM Scripts Using FZF
function fns() {
  log "Running NPM scripts using FZF" "$log_file_name"
  if [[ -f package.json ]]; then
    local content script
    content="$(jq -r '.scripts' package.json)"
    script=$(jq -r '.scripts | keys[] ' package.json | sort -u | fzf --preview="echo 'Script -> {}\n';grep '{}' package.json | sed 's/^[ ]*//g'")
    if [[ "$script" != "" ]]; then
      n "$script"
    fi
  fi
}

# Update FZF from Source
function fzf-update() {
  log "Updating FZF from source" "$log_file_name"
  local dir
  dir="$(pwd)"
  cd ~/.fzf && git pull && ./install --no-bash --no-zsh --no-fish --no-key-bindings --no-completion --no-update-rc
  cd "$dir"
  exec $SHELL -l
}

# Open Files Using FZF
function files() {
  log "Opening files using FZF" "$log_file_name"
  local file
  file="$(fzf --multi --reverse)"
  if [[ "$file" ]]; then
    for prog in $(echo "$file"); do
      $EDITOR "$prog"
    done
  else
    echo "Cancelled FZF"
    log "FZF file selection cancelled" "$log_file_name"
  fi
}

# Git Status Using FZF
function st() {
  git rev-parse --git-dir >/dev/null 2>&1 || {
    log "Not in a git repository" "$log_file_name"
    echo "You are not in a git repository"
    return
  }
  local selected
  selected=$(git -c color.status=always status --short |
    fzf --no-height --cycle "$@" --border -m --ansi --nth 2..,.. \
      --preview '(if [ -d {-1} ];then lsd -l {-1}; else git diff --color=always -- {-1} | delta --side-by-side -w "$(tput cols)-45" | sed 1,4d; cat {-1}; fi)' |
    cut -c4- | sed 's/.* -> //')
  if [[ $selected ]]; then
    for prog in $(echo "$selected"); do
      $EDITOR "$prog"
    done
  fi
  log "Selected files for editing using FZF and git status: $selected" "$log_file_name"
}

#############################################################################################################################
## FZF Completion
#############################################################################################################################

export FZF_COMPLETION_TRIGGER=''
bindkey "^I" expand-or-complete
bindkey "^[[Z" expand-or-complete
bindkey '^ ' fzf-completion
bindkey '^I' $fzf_default_completion

# FZF Path Completion Generator
function _fzf_compgen_path() {
  log "Generating FZF path completion" "$log_file_name"
  bfs -H "$1" -color -exclude \( -name .git \) 2>/dev/null
}

# FZF Directory Completion Generator
function _fzf_compgen_dir() {
  log "Generating FZF directory completion" "$log_file_name"
  bfs -H "$1" -color -exclude \( -name .git \) -type d 2>/dev/null
}
