#!/bin/bash

tmd() {
  log "Killing tmux session" "tmd.log"
  local session=$(tmux list-sessions -F "#S" 2>/dev/null | fzf --exit-0)
  [ -n "$session" ] && tmux kill-session -t "$session"
}
