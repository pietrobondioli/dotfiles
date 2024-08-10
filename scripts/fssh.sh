#!/bin/bash

fssh() {
  log "Connecting to SSH host" "fssh.log"
  local host=$(grep "Host " ~/.ssh/config | awk '{print $2}' | fzf --exit-0)
  [ -n "$host" ] && ssh "$host"
}
