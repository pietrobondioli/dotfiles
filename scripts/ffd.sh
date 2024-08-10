#!/bin/bash

ffd() {
  log "Finding and navigating to directory" "ffd.log"
  local dir
  if [ -z "$1" ]; then
    dir="$(find ~/personal ~/work ~/mack-ads ~/ -type d -maxdepth 5 -mindepth 1 -print 2>/dev/null | fzf)"
  else
    dir="$(find "$1" -type d -maxdepth 5 -mindepth 1 -print 2>/dev/null | fzf)"
  fi
  [ -n "$dir" ] && cd "$dir" && l
}
