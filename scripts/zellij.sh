#######
# Zellij Functions
#######

# Prune all Zellij sessions
zjp() {
  log "Pruning all Zellij sessions..." "zjp.log"

  echo "WARNING: this action will kill all sessions."
  echo -n "Do you want to continue? [y/n] "
  read choice

  if [[ "$choice" =~ ^[yY]$ ]]; then
    log "User confirmed deleting all sessions. Proceeding..." "zjp.log"
    zellij ka -y 2>/dev/null
    zellij da -y -f 2>/dev/null
    log "All sessions pruned." "zjp.log"
    echo "All sessions pruned."
  else
    log "Operation cancelled by user." "zjp.log"
    echo "Operation cancelled."
  fi
}

# Select and delete Zellij sessions
zjd() {
  log "Fetching Zellij sessions for user selection..." "zjd.log"

  local sessions
  sessions=$(zellij list-sessions | grep -o '^\S*' | sed 's/\x1b\[[0-9;]*m//g')

  if [[ -z "$sessions" ]]; then
    log "No existing Zellij sessions found. Exiting script." "zjd.log"
    echo "No Zellij sessions found."
    return
  fi

  log "Prompting user to select sessions to kill and delete using fzf..." "zjd.log"
  local choice
  choice=$(echo -e "None\n$sessions" | fzf --header="Select sessions to kill and delete (Use TAB to select multiple, ESC or None to cancel):" --multi --no-clear)

  if [[ -z "$choice" ]] || [[ "$choice" == "None" ]]; then
    log "User selected 'None' or cancelled selection. Exiting script without any action." "zjd.log"
    echo "No sessions selected. Exiting."
    return
  fi

  log "User selected sessions: $choice" "zjd.log"
  echo "WARNING: This action will delete the selected sessions:"
  echo "$choice"
  echo
  echo -n "Do you want to continue? [y/n] "
  read -r confirm
  if [[ "$confirm" =~ ^[yY]$ ]]; then
    echo "$choice" | while IFS= read -r session; do
      log "Killing session: $session" "zjd.log"
      zellij kill-session "$session" 2>/dev/null
      log "Deleting session: $session" "zjd.log"
      zellij delete-session "$session" -f 2>/dev/null
    done
    log "Selected sessions have been deleted." "zjd.log"
    echo "Selected sessions have been deleted."
  else
    log "Operation cancelled by user." "zjd.log"
    echo "Operation cancelled."
  fi
}
