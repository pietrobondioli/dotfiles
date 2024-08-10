#!/bin/bash

pfc() {
  local depth=1
  local pattern="*"
  local log_file="pfc.log"

  # Get the directory argument and shift it off so getopts doesn't process it
  local dir="$1"
  shift

  if [[ -z "$dir" ]]; then
    echo "Usage: pfc <directory> [-d depth] [-p pattern]" && return 1
  fi

  # Parse optional depth and pattern arguments
  while getopts "d:p:" opt; do
    case $opt in
    d) depth="$OPTARG" ;;
    p) pattern="$OPTARG" ;;
    *) echo "Usage: pfc <directory> [-d depth] [-p pattern]" && return 1 ;;
    esac
  done

  # Log the operation
  log "Searching in directory: $dir with depth: $depth and pattern: $pattern" "$log_file"

  # Execute the find command and log any errors
  find "$dir" -maxdepth "$depth" -type f -name "$pattern" -exec echo -e "\n--- {} ---\n" \; -exec cat {} \; 2>>"$USER_LOG_DIR/$log_file"

  # Log completion
  log "Completed searching in directory: $dir" "$log_file"
}
