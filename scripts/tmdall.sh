#!/bin/bash

tmdall() {
  log "Killing all tmux sessions except current" "tmdall.log"
  local current_session=$(tmux display-message -p '#S')

  tmux list-sessions -F "#S" | while read session_name; do
    if [[ "$session_name" != "$current_session" ]]; then
      tmux kill-session -t "$session_name"
    fi
  done
}
