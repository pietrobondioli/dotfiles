#!/bin/bash

# Set log file name
log_file_name="git.log"

#############################################################################################################################
## Git Functions
#############################################################################################################################

# Load Git version for compatibility checks
autoload -Uz is-at-least
git_version=$(git version 2>/dev/null | awk '{print $3}')

# Update repositories in specific paths
function update_my_repos() {
  local paths=(
    "$HOME/work/essencial/repos"
    "$HOME/work/syniti/repos"
    "$HOME/personal/projects"
    "$HOME/personal/sandbox"
  )

  for path in "${paths[@]}"; do
    log "Updating repositories in $path" "$log_file_name"
    update_repos "$path"
  done
}

# Update repositories at the specified path
function update_repos() {
  local REPO_PATH="$1"

  if [ -z "$REPO_PATH" ]; then
    log "No repository path provided. Usage: update_repos /path/to/repos" "$log_file_name"
    return 1
  fi

  if [ -z "$USER_LOG_DIR" ]; then
    log "Error: USER_LOG_DIR is not set. Please define it in your zshrc or bashrc." "$log_file_name"
    return 1
  fi

  mkdir -p "$USER_LOG_DIR"
  local LOG_FILE="$USER_LOG_DIR/git_fetch_log_$(date +%Y%m%d_%H%M%S).log"

  log "Updating repositories in $REPO_PATH" "$log_file_name"
  find "$REPO_PATH" -maxdepth 4 -name ".git" -prune -type d -printf "%h\n" |
    parallel --eta "echo {} >> $LOG_FILE && git -C {} fetch --verbose >> $LOG_FILE 2>&1 || echo 'Failed to fetch for repo: {}' >> $LOG_FILE" --timeout 300

  log "Fetch operations completed. Log file saved as $LOG_FILE" "$log_file_name"
}

# Get the current branch name
function current_branch() {
  local branch_name
  branch_name=$(git_current_branch)
  log "Current branch: $branch_name" "$log_file_name"
  echo "$branch_name"
}

# Display Git log with a specific format
function _git_log_prettily() {
  if [ -n "$1" ]; then
    git log --pretty="$1"
    log "Displayed git log with format: $1" "$log_file_name"
  fi
}

# Display a message if work in progress (WIP) commits are present
function work_in_progress() {
  if command git -c log.showSignature=false log -n 1 2>/dev/null | grep -q -- "--wip--"; then
    log "Work in progress detected" "$log_file_name"
    echo "WIP!!"
  fi
}

# Determine the main branch (main, master, etc.)
function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default}; do
    if command git show-ref -q --verify "$ref"; then
      log "Main branch detected: ${ref:t}" "$log_file_name"
      echo "${ref:t}"
      return
    fi
  done
  log "Defaulting to 'master' branch" "$log_file_name"
  echo "master"
}

# Determine the development branch (develop, dev, etc.)
function git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local branch
  for branch in dev devel development; do
    if command git show-ref -q --verify refs/heads/$branch; then
      log "Development branch detected: $branch" "$log_file_name"
      echo "$branch"
      return
    fi
  done
  log "Defaulting to 'develop' branch" "$log_file_name"
  echo develop
}

# Get a branch name using fzf
function getBranchFzf() {
  local branch
  branch=$(git branch --sort=-committerdate | sed 's/* //g' | sed 's/  //g' | grep -v "$(git branch --show-current)" | fzf --ansi --info inline --preview "echo Branch: {};echo; git log -n 20 --oneline {}" | tr -d ';')
  log "Selected branch: $branch" "$log_file_name"
  echo "$branch"
}

# Count the number of commits in the current pull request
function countCommits() {
  local commit_count
  commit_count=$(gh pr view --json commits | jq '.commits|length' | tr -d "\n")
  log "Number of commits in current PR: $commit_count" "$log_file_name"
  echo "$commit_count"
}

unset git_version

#############################################################################################################################
## Git Aliases
#############################################################################################################################

alias pushf="git push --force-with-lease"
alias add='git add'
alias checkout='git checkout'
alias gcb='git checkout -b'
alias gcd='git checkout "$(git_develop_branch)"'
alias gcf='git config --list'
alias gcm='git checkout "$(git_main_branch)"'
alias gd='git diff'
alias gitree='git log --oneline --graph --decorate --all'
alias gitree='git-graph'
alias gittree='git-graph'
alias gst='git status'
alias gtv='git tag | sort -V'
alias logs='forgit::log'
alias pull='git pull'
alias push='git push -u'
alias rebase='git rebase'
alias tags='git tag | sort -V'

#############################################################################################################################
## GitHub CLI Aliases
#############################################################################################################################

alias ghc='gh pr checkout'
alias ghl='gh pr list'
alias gdash="gh dash"

#############################################################################################################################
## Git Utility Functions
#############################################################################################################################

# Checkout a branch using fzf
function gco() {
  local branch
  branch=$(_fzf_git_each_ref --no-multi | xargs git checkout)
  log "Checked out branch: $branch" "$log_file_name"
}

# Clone a GitHub repository using SSH
function clone() {
  git clone "git@github.com:$1"
  log "Cloned repository: git@github.com:$1" "$log_file_name"
}

# Create a WIP commit
function wip() {
  git add -A .
  local now
  now=$(date +"%Y-%m-%dT%H:%M:%S TZ%Z(%a, %j)")
  git commit --no-verify -S -m "wip: checkpoint at $now"
  git push
  log "Created WIP commit at $now" "$log_file_name"
}

# Pull and rebase the current branch
function pullb() {
  git fetch
  local current_branch
  current_branch=$(git branch --show-current)
  git pull --rebase origin "$current_branch"
  log "Pulled and rebased branch: $current_branch" "$log_file_name"
}

# Open GitHub PRs using a custom script
function prs() {
  bash "$DOTFILES/bin/gh-fzf"
  log "Opened GitHub PR list" "$log_file_name"
}

# Delete all branches except main, master, and develop
function killbranches() {
  git for-each-ref --format '%(refname:short)' refs/heads | grep -v "master\|main\|develop" | xargs git branch -D
  log "Deleted non-essential branches" "$log_file_name"
}

# Create a Git tag and push it to the remote
function tag() {
  git tag "$1"
  git push origin "$1"
  log "Created and pushed tag: $1" "$log_file_name"
}

# Rebase the current branch with another branch
function rebasewith() {
  git fetch
  local current_branch target_branch
  current_branch="$(git rev-parse --abbrev-ref HEAD)"
  target_branch="$1"
  git switch "$target_branch"
  git pull origin "$target_branch"
  git switch "$current_branch"
  git rebase "$target_branch"
  log "Rebased $current_branch with $target_branch" "$log_file_name"
}

# Interactive rebase with a specified number of commits
function squash() {
  git rebase -i "HEAD~${1}"
  log "Squashed the last ${1} commits" "$log_file_name"
}

# Squash commits in the current branch based on the number of commits in the pull request
function squashbranch() {
  local commits
  commits=$(test -z "$1" && echo "$(countCommits)" || echo "$1")
  log "Squashing the last $commits commits" "$log_file_name"
  echo "Rebase '$commits' behind...Press ENTER to continue"
  read -r
  squash "$commits"
}

# Switch to another branch using fzf
function switch() {
  local branch_target
  branch_target=$(test -z "$1" && echo "$(getBranchFzf)" || echo "$1")
  git switch "$branch_target"
  log "Switched to branch: $branch_target" "$log_file_name"
}

# Add entries to .gitignore using a custom script
function gitignore() {
  forgit::ignore >>".gitignore"
  log "Added entries to .gitignore" "$log_file_name"
}

# Display Git commit graph
function git-graph() {
  git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%ae>%Creset" --abbrev-commit --all
  log "Displayed Git commit graph" "$log_file_name"
}

# Create a signed commit with an optional message
function commit() {
  if [[ -z "$1" ]]; then
    git commit -S
    log "Created a signed commit without a message" "$log_file_name"
  else
    git commit -S -m "$1"
    log "Created a signed commit with message: $1" "$log_file_name"
  fi
}

# Get the last commit message with timestamp
function lastcommit() {
  local message
  message=$(git log --pretty='format:%s 🕑 %cr' 'HEAD^..HEAD' | head -n 1)
  log "Last commit message: $message" "$log_file_name"
  echo "$message"
}

#############################################################################################################################
## GitHub Functions
#############################################################################################################################

# Create a GitHub pull request
function createpr() {
  local branch_target
  branch_target=$(test -z "$1" && echo "$(getBranchFzf)" || echo "$1")
  gh pr create --base "$branch_target" -a "@me" "${@:2}"
  log "Created GitHub PR based on branch: $branch_target" "$log_file_name"
}

# Alias for creating a pull request
function newpr() {
  createpr "$1"
}

# Create a draft GitHub pull request
function draft() {
  createpr "$1" "--draft"
  log "Created draft GitHub PR based on branch: $1" "$log_file_name"
}
