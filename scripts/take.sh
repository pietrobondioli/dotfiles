#!/bin/bash

take() {
  log "Creating and moving to directory: $1" "take.log"
  mkdir -p "$1"
  if cd "$1"; then
    log "Changed directory to $1" "take.log"
  else
    log "Failed to change directory to $1" "take.log"
  fi
}
