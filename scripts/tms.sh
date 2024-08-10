#!/bin/bash

tms() {
  log "Switching to tmux session" "tms.log"
  local session=$(tmux list-sessions -F "#S" 2>/dev/null | fzf --exit-0)
  [ -n "$session" ] && tmux switch -t "$session"
}
