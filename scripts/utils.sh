#!/bin/bash

# Define the log file name
log_file_name="utils.log"

#######
# FZF Configuration
#######
# One Dark
export FZF_COLORS="
--color=dark
--color='bg+:#3A3F4B,bg:#282C34,spinner:#E5C07B,hl:#C678DD'
--color='fg:#ABB2BF,header:#C678DD,info:#56B6C2,pointer:#E06C75'
--color='marker:#98C379,fg+:#ABB2BF,prompt:#61AFEF,hl+:#C678DD'
"

# Catppuccin Frappe
# export FZF_COLORS="
# --color=dark
# --color='bg+:#292c3c,bg:#232634,spinner:#f2d5cf,hl:#f4b8e4'
# --color='fg:#c6d0f5,header:#ca9ee6,info:#99d1db,pointer:#f4b8e4'
# --color='marker:#e78284,fg+:#b5bfe2,prompt:#8caaee,hl+:#f4b8e4'
# "

#######
# Utility Functions
#######

# Check if a command exists, otherwise execute a fallback command
function checkcommand() {
  if command -v "$1" &>/dev/null; then
    mylog "Command $1 found" "$log_file_name"
    return 0
  else
    mylog "Command $1 not found, executing fallback" "$log_file_name"
    $2
  fi
}

# Check if the directory is a Git repository
function isGitDir() {
  local dir="$1"
  if git -C "$dir" rev-parse --is-inside-work-tree &>/dev/null; then
    mylog "Directory $dir is a Git repository" "$log_file_name"
    echo "true"
  else
    mylog "Directory $dir is not a Git repository" "$log_file_name"
    echo "false"
  fi
}

# Get the current branch of a Git repository
function getCurrentBranch() {
  local dir="$1"
  local branch
  branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
  mylog "Current branch for $dir is $branch" "$log_file_name"
  echo "$branch"
}

# Get the repository name from the remote URL
function getRepositoryName() {
  local dir="$1"
  local repo_name
  repo_name=$(git -C "$dir" config --get remote.origin.url 2>/dev/null | cut -d ':' -f2- | sed 's/\.git$//g')
  mylog "Repository name for $dir is $repo_name" "$log_file_name"
  echo "$repo_name"
}

# Get the basename of a file, including its parent directory
function basename2() {
  local path="$1"
  local result
  result=$(basename "$(dirname "$path")")/$(basename "$path")
  mylog "Basename for $path is $result" "$log_file_name"
  echo "$result"
}

# Execute a command for each item in a space-separated list
function forEach() {
  local items="$1"
  local command="$2"
  local item

  mylog "Executing $command for each item in list: $items" "$log_file_name"

  for item in $(echo "$items" | tr ' ' '\n'); do
    "$command" "$item"
    mylog "Executed $command for item: $item" "$log_file_name"
  done
}
