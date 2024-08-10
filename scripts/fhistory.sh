#!/bin/bash

fhistory() {
  log "Fetching and displaying command history" "fhistory.log"
  fc -R

  # Use fc -l to get the history list with commands
  local command=$(fc -l -n 1 | fzf --tac)

  if [ -n "$command" ]; then
    log "Selected command: $command" "fhistory.log"
    echo "$command" | copy
    echo "$command"
  else
    log "No command selected" "fhistory.log"
  fi
}
