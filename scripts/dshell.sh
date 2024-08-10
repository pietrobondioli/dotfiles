#!/bin/bash

dshell() {
  log "Entering Docker container shell" "dshell.log"
  local container=$(docker ps --format '{{.Names}}' | fzf --exit-0)
  [ -n "$container" ] && docker exec -it "$container" /bin/sh
}
