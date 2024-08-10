#!/bin/bash

log_file="zjd.log"

get_zellij_sessions() {
  zellij list-sessions | grep -o '^\S*' | sed 's/\x1b\[[0-9;]*m//g'
}

zjd() {
  log "Fetching Zellij sessions for user selection..." "$log_file"

  local sessions
  sessions=$(get_zellij_sessions)

  if [[ -z "$sessions" ]]; then
    log "No existing Zellij sessions found. Exiting script." "$log_file"
    echo "No Zellij sessions found."
    return
  fi

  log "Prompting user to select sessions to kill and delete using fzf..." "$log_file"
  local choice
  choice=$(echo -e "None\n$sessions" | fzf --header="Select sessions to kill and delete (Use TAB to select multiple, ESC or None to cancel):" --multi --no-clear)

  if [[ -z "$choice" ]] || [[ "$choice" == "None" ]]; then
    log "User selected 'None' or cancelled selection. Exiting script without any action." "$log_file"
    echo "No sessions selected. Exiting."
    return
  fi

  log "User selected sessions: $choice" "$log_file"
  echo "WARNING: This action will delete the selected sessions:"
  echo "$choice"
  echo
  echo -n "Do you want to continue? [y/n] "
  read -r confirm
  if [[ "$confirm" =~ ^[yY]$ ]]; then
    echo "$choice" | while IFS= read -r session; do
      log "Killing session: $session" "$log_file"
      zellij kill-session "$session" 2>/dev/null
      log "Deleting session: $session" "$log_file"
      zellij delete-session "$session" -f 2>/dev/null
    done
    log "Selected sessions have been deleted." "$log_file"
    echo "Selected sessions have been deleted."
  else
    log "Operation cancelled by user." "$log_file"
    echo "Operation cancelled."
  fi
}
