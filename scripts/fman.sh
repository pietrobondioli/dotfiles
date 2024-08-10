#!/bin/bash

fman() {
  log "Finding and displaying man page" "fman.log"
  local manpage=$(man -k . | awk '{print $1}' | sort | uniq | fzf --exit-0)
  [ -n "$manpage" ] && man "$manpage"
}
