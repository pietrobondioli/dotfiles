#######
# Tmux Functions
#######

# Start or switch to a tmux session
tmo() {
  log "Starting tmux session" "tmo.log"
  local selected

  if [[ $# -eq 1 ]]; then
    selected=$1
  else
    selected=$(find ~/work ~/projects ~/sandbox ~/ -mindepth 1 -maxdepth 2 -type d | fzf)
  fi

  if [[ -z $selected ]]; then
    return 0
  fi

  local selected_name=$(basename "$selected" | tr . _)
  local tmux_running=$(pgrep tmux)

  if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    return 0
  fi

  if ! tmux has-session -t=$selected_name 2>/dev/null; then
    tmux new-session -ds $selected_name -c $selected
  fi

  tmux switch-client -t $selected_name
}

# Switch to an existing tmux session
tms() {
  log "Switching to tmux session" "tms.log"
  local session=$(tmux list-sessions -F "#S" 2>/dev/null | fzf --exit-0)
  [ -n "$session" ] && tmux switch -t "$session"
}

# Kill a tmux session
tmd() {
  log "Killing tmux session" "tmd.log"
  local session=$(tmux list-sessions -F "#S" 2>/dev/null | fzf --exit-0)
  [ -n "$session" ] && tmux kill-session -t "$session"
}

# Kill all tmux sessions except the current one
tmdall() {
  log "Killing all tmux sessions except current" "tmdall.log"
  local current_session=$(tmux display-message -p '#S')

  tmux list-sessions -F "#S" | while read session_name; do
    if [[ "$session_name" != "$current_session" ]]; then
      tmux kill-session -t "$session_name"
    fi
  done
}
