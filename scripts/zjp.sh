#!/bin/bash

log_file="zjp.log"

zjp() {
  log "Pruning all Zellij sessions..." "$log_file"

  echo "WARNING: this action will kill all sessions."
  echo -n "Do you want to continue? [y/n] "
  read choice

  if [[ "$choice" =~ ^[yY]$ ]]; then
    log "User confirmed deleting all sessions. Proceeding..." "$log_file"
    zellij ka -y 2>/dev/null
    zellij da -y -f 2>/dev/null
    log "All sessions pruned." "$log_file"
    echo "All sessions pruned."
  else
    log "Operation cancelled by user." "$log_file"
    echo "Operation cancelled."
  fi
}
