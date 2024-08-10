#######
# Navigation Functions
#######

# Change directory to the root of the git repository
cdtoroot() {
  cd "$(git rev-parse --show-toplevel)"
}

# Creating and moving to directory
take() {
  log "Creating and moving to directory: $1" "take.log"
  mkdir -p "$1"
  if cd "$1"; then
    log "Changed directory to $1" "take.log"
  else
    log "Failed to change directory to $1" "take.log"
  fi
}

# Finding and navigating to directory
ffd() {
  log "Finding and navigating to directory" "ffd.log"
  local dir
  if [ -z "$1" ]; then
    dir="$(find ~/personal ~/work ~/mack-ads ~/ -type d -maxdepth 5 -mindepth 1 -print 2>/dev/null | fzf)"
  else
    dir="$(find "$1" -type d -maxdepth 5 -mindepth 1 -print 2>/dev/null | fzf)"
  fi
  [ -n "$dir" ] && cd "$dir" && l
}
