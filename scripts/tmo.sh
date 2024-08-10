#!/bin/bash

tmo() {
  log "Starting tmux session" "tmo.log"
  local selected

  if [[ $# -eq 1 ]]; then
    selected=$1
  else
    selected=$(find ~/work ~/projects ~/sandbox ~/ -mindepth 1 -maxdepth 2 -type d | fzf)
  fi

  if [[ -z $selected ]]; then
    return 0
  fi

  local selected_name=$(basename "$selected" | tr . _)
  local tmux_running=$(pgrep tmux)

  if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    return 0
  fi

  if ! tmux has-session -t=$selected_name 2>/dev/null; then
    tmux new-session -ds $selected_name -c $selected
  fi

  tmux switch-client -t $selected_name
}
