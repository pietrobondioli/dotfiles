#!/bin/bash

fv() {
  log "Finding and opening file with nvim" "fv.log"
  local path

  if [ -n "$1" ]; then
    path="$1"
  else
    path=(~/work ~/personal/projects ~/personal/sandbox ~/)
  fi

  local file=$(find "${path[@]}" -type f -print 2>/dev/null | fzf +m) || {
    echo "No files found"
    return 1
  }

  local dir=$(dirname "$file")
  local filename=$(basename "$file")

  if [ -n "$dir" ]; then
    cd "$dir" || {
      echo "Unable to change directory"
      return 1
    }
  else
    echo "No selection made"
    return 1
  fi

  [ -n "$filename" ] && nvim "$filename"
}
