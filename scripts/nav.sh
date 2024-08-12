#######
# Navigation Functions
#######

log_file_name="nav.log"

# Change directory to the root of the git repository
cdtoroot() {
  cd "$(git rev-parse --show-toplevel)"
}

# Creating and moving to directory
take() {
  mylog "Creating and moving to directory: $1" "$log_file_name"
  mkdir -p "$1"
  if cd "$1"; then
    mylog "Changed directory to $1" "$log_file_name"
  else
    mylog "Failed to change directory to $1" "$log_file_name"
  fi
}

# Finding and navigating to directory
ffd() {
  mylog "Finding and navigating to directory" "$log_file_name"
  local dir
  if [ -z "$1" ]; then
    dir="$(find ~/personal ~/work ~/mack-ads ~/ -type d -maxdepth 5 -mindepth 1 -print 2>/dev/null | fzf)"
  else
    dir="$(find "$1" -type d -maxdepth 5 -mindepth 1 -print 2>/dev/null | fzf)"
  fi
  [ -n "$dir" ] && cd "$dir" && l
}
