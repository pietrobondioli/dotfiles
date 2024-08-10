#!/bin/bash

fkill() {
  log "Finding and killing process" "fkill.log"
  local pid=$(ps aux | sed 1d | fzf -m | awk '{print $2}')
  [ -n "$pid" ] && kill -9 "$pid" && echo "Killed $pid"
}
