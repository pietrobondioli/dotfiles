#!/bin/bash

log_file="zellij_autostart.log"

is_in_editor_or_ide() {
  pstree -s $$ | grep -E 'nvim|vim|code|jetbrains|java' &>/dev/null
}

get_zellij_sessions() {
  zellij list-sessions | grep -o '^\S*' | sed 's/\x1b\[[0-9;]*m//g'
}

attach_session() {
  local session_name="$1"
  mylog "Attaching to Zellij session with name: $session_name" "$log_file"
  zellij attach -c "$session_name"
}

is_valid_session_name() {
  [[ "$1" =~ ^[a-z]+(-[a-z]+)*$ ]]
}

zellij_autostart_config() {
  if [[ -n "$ZELLIJ_AUTOSTART_CONFIG_RAN" ]]; then
    mylog "Script already ran in the current shell. Exiting script." "$log_file"
    return
  fi

  if [[ -n "$ZELLIJ" ]]; then
    mylog "Already in a Zellij session. Exiting script." "$log_file"
    return
  fi

  mylog "Checking if the current environment is inside an IDE or terminal editor..." "$log_file"
  if is_in_editor_or_ide; then
    mylog "Running inside an IDE (VS Code, JetBrains) or a terminal editor (Neovim/Vim). Not starting Zellij." "$log_file"
    return
  fi

  mylog "Environment not detected as Neovim or VS Code. Proceeding with Zellij." "$log_file"
  local sessions
  sessions=$(get_zellij_sessions)
  if [[ -z "$sessions" ]]; then
    mylog "No existing Zellij sessions found. Creating a new session..." "$log_file"
    choices="Start without Zellij\nCreate new session"
  else
    mylog "Existing sessions found. Preparing choice menu for Zellij sessions..." "$log_file"
    choices="Start without Zellij\n$sessions\nCreate new session"
  fi

  local choice
  choice=$(echo -e "$choices" | fzf --print-query | tail -1)

  if [[ -z "$choice" ]] || [[ "$choice" == "Start without Zellij" ]]; then
    mylog "No selection or 'Start without Zellij' selected. Exiting script without starting Zellij." "$log_file"
    # set the environment variable to prevent running the script again in the current shell
    export ZELLIJ_AUTOSTART_CONFIG_RAN=true
    return
  fi

  if [[ "$choice" == "Create new session" ]] || ! is_valid_session_name "$choice"; then
    mylog "Invalid or no session name provided, creating new session with generated name..." "$log_file"
    local new_session
    new_session=$(coolname)
    attach_session "$new_session"
    return
  fi

  attach_session "$choice"
}
