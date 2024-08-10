#!/bin/bash

# Function to log messages
log() {
	logger "$1"
}

# Function to check for IDEs or terminal editors
is_in_editor_or_ide() {
	pstree -s $$ | grep -E 'nvim|vim|code|jetbrains' &>/dev/null
}

# Function to list Zellij sessions and remove ANSI codes
get_zellij_sessions() {
	zellij list-sessions | grep -o '^\S*' | sed 's/\x1b\[[0-9;]*m//g'
}

# Function to attach to Zellij session
attach_session() {
	local session_name="$1"
	log "Attaching to Zellij session with name: $session_name"
	zellij attach -c "$session_name"
}

# Function to validate session name format (kebab-case)
is_valid_session_name() {
	[[ "$1" =~ ^[a-z]+(-[a-z]+)*$ ]]
}

# Main function to control flow
zellij_autostart_config() {
	# Check if script already ran in the current shell
	if [[ -n "$ZELLIJ_AUTOSTART_CONFIG_RAN" ]]; then
		log "Script already ran in the current shell. Exiting script."
		return
	fi

	# Check if running within a Zellij session
	if [[ -n "$ZELLIJ" ]]; then
		log "Already in a Zellij session. Exiting script."
		return
	fi

	log "Checking if the current environment is inside an IDE or terminal editor..."
	if is_in_editor_or_ide; then
		log "Running inside an IDE (VS Code, JetBrains) or a terminal editor (Neovim/Vim). Not starting Zellij."
		return
	fi

	log "Environment not detected as Neovim or VS Code. Proceeding with Zellij."
	local sessions=$(get_zellij_sessions)
	if [[ -z "$sessions" ]]; then
		log "No existing Zellij sessions found. Creating a new session..."
		local new_session=$(coolname)
		attach_session "$new_session"
		return
	fi

	log "Existing sessions found. Preparing choice menu for Zellij sessions..."
	local choices="$sessions\nCreate new session\nStart without Zellij"
	local choice=$(echo -e "$choices" | fzf --print-query | tail -1)

	if [[ "$choice" == "Start without Zellij" ]]; then
		log "Starting without Zellij as selected."
		# set the environment variable to prevent running the script again in the current shell
		export ZELLIJ_AUTOSTART_CONFIG_RAN=true
		return
	fi

	if [[ "$choice" == "Create new session" ]] || ! is_valid_session_name "$choice"; then
		log "Invalid or no session name provided, creating new session with generated name..."
		local new_session=$(coolname)
		attach_session "$new_session"
		return
	fi

	attach_session "$choice"
}

# Call the function to execute the script logic
zellij_autostart_config
