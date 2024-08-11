#!/bin/bash

# Logging function
log() {
  local message="$1"
  local log_file_name="${2:-default.log}"
  local log_file="$USER_LOG_DIR/$log_file_name"

  # Ensure the log directory exists
  mkdir -p "$USER_LOG_DIR"

  # Log to syslog
  logger "$message"

  # Log to the specified log file with a timestamp
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >>"$log_file"
}

# Define the log file name
log_file_name="utils.log"

#######
# FZF Configuration
#######
export FZF_COLORS="
--color=dark
--color='bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8'
--color='fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc'
--color='marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'"

#######
# Utility Functions
#######

# Check if a command exists, otherwise execute a fallback command
function checkcommand() {
  if command -v "$1" &>/dev/null; then
    log "Command $1 found" "$log_file_name"
    return 0
  else
    log "Command $1 not found, executing fallback" "$log_file_name"
    $2
  fi
}

# Check if the directory is a Git repository
function isGitDir() {
  local dir="$1"
  if git -C "$dir" rev-parse --is-inside-work-tree &>/dev/null; then
    log "Directory $dir is a Git repository" "$log_file_name"
    echo "true"
  else
    log "Directory $dir is not a Git repository" "$log_file_name"
    echo "false"
  fi
}

# Get the current branch of a Git repository
function getCurrentBranch() {
  local dir="$1"
  local branch
  branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
  log "Current branch for $dir is $branch" "$log_file_name"
  echo "$branch"
}

# Get the repository name from the remote URL
function getRepositoryName() {
  local dir="$1"
  local repo_name
  repo_name=$(git -C "$dir" config --get remote.origin.url 2>/dev/null | cut -d ':' -f2- | sed 's/\.git$//g')
  log "Repository name for $dir is $repo_name" "$log_file_name"
  echo "$repo_name"
}

# Get the basename of a file, including its parent directory
function basename2() {
  local path="$1"
  local result
  result=$(basename "$(dirname "$path")")/$(basename "$path")
  log "Basename for $path is $result" "$log_file_name"
  echo "$result"
}

# Execute a command for each item in a space-separated list
function forEach() {
  local items="$1"
  local command="$2"
  local item

  log "Executing $command for each item in list: $items" "$log_file_name"

  for item in $(echo "$items" | tr ' ' '\n'); do
    "$command" "$item"
    log "Executed $command for item: $item" "$log_file_name"
  done
}
