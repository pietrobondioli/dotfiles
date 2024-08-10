#!/bin/bash

cfgedit() {
  log "Opening configuration file with vim" "cfgedit.log"
  local file=$(find ~/.* -maxdepth 2 -type f | fzf --exit-0)
  [ -n "$file" ] && vim "$file"
}
