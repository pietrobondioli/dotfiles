#!/bin/bash

update_repos() {
  local REPO_PATH="$1"

  if [ -z "$REPO_PATH" ]; then
    echo "Usage: update_repos /path/to/repos"
    return 1
  fi

  if [ -z "$USER_LOG_DIR" ]; then
    echo "Error: USER_LOG_DIR is not set. Please define it in your zshrc or bashrc."
    return 1
  fi

  mkdir -p "$USER_LOG_DIR"
  local LOG_FILE="$USER_LOG_DIR/git_fetch_log_$(date +%Y%m%d_%H%M%S).log"

  log "Updating repositories in $REPO_PATH" "update_repos.log"
  find "$REPO_PATH" -maxdepth 4 -name ".git" -prune -type d -printf "%h\n" |
    parallel --eta "echo {} >> $LOG_FILE && git -C {} fetch --verbose >> $LOG_FILE 2>&1 || echo 'Failed to fetch for repo: {}' >> $LOG_FILE" --timeout 300

  echo "Fetch operations completed. Log file saved as $LOG_FILE"
}
