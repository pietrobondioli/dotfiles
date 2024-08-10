#######
# Utility Functions
#######

# Copy last command output
clc() {
  if [[ -z "$1" ]]; then
    local last_command_output
    last_command_output=$(fc -ln -1 | sed 's/^[ \t]*//;s/[ \t]*$//' | bash 2>&1)

    if [[ -n "$last_command_output" ]]; then
      echo "$last_command_output" | copy
    else
      echo "No output from last command."
    fi

    echo "Last command output copied to clipboard."
  else
    echo "Usage: copy_last_command_output"
  fi
}

# Finding and opening file with nvim
fv() {
  log "Finding and opening file with nvim" "fv.log"
  local path

  if [ -n "$1" ]; then
    path="$1"
  else
    path=(~/work ~/personal/projects ~/personal/sandbox ~/)
  fi

  local file=$(find "${path[@]}" -type f -print 2>/dev/null | fzf +m) || {
    echo "No files found"
    return 1
  }

  local dir=$(dirname "$file")
  local filename=$(basename "$file")

  if [ -n "$dir" ]; then
    cd "$dir" || {
      echo "Unable to change directory"
      return 1
    }
  else
    echo "No selection made"
    return 1
  fi

  [ -n "$filename" ] && nvim "$filename"
}

# Open configuration file with vim
cfgedit() {
  log "Opening configuration file with vim" "cfgedit.log"
  local file=$(find ~/.* -maxdepth 2 -type f | fzf --exit-0)
  [ -n "$file" ] && vim "$file"
}

# Enter Docker container shell
dshell() {
  log "Entering Docker container shell" "dshell.log"
  local container=$(docker ps --format '{{.Names}}' | fzf --exit-0)
  [ -n "$container" ] && docker exec -it "$container" /bin/sh
}

# Find and kill process
fkill() {
  log "Finding and killing process" "fkill.log"
  local pid=$(ps aux | sed 1d | fzf -m | awk '{print $2}')
  [ -n "$pid" ] && kill -9 "$pid" && echo "Killed $pid"
}

# Find and display man page
fman() {
  log "Finding and displaying man page" "fman.log"
  local manpage=$(man -k . | awk '{print $1}' | sort | uniq | fzf --exit-0)
  [ -n "$manpage" ] && man "$manpage"
}

# Fetch and display command history
fhistory() {
  log "Fetching and displaying command history" "fhistory.log"
  fc -R

  local command=$(fc -l -n 1 | fzf --tac)

  if [ -n "$command" ]; then
    log "Selected command: $command" "fhistory.log"
    echo "$command" | copy
    echo "$command"
  else
    log "No command selected" "fhistory.log"
  fi
}

# Open cheat sheet
chsheet() {
  log "Opening cheat sheet for $selected" "chsheet.log"
  local languages=("csharp" "css" "go" "java" "dotnet" "html" "http" "javascript" "linux" "lua" "mysql" "nodejs" "python" "rust" "sql" "vim")
  local commands=("curl" "date" "docker" "find" "mv" "rm" "ssh" "tar" "unzip" "wget" "zip" "awk" "cat" "chmod" "chown" "cp" "curl" "diff" "du" "grep" "tail" "touch" "wc" "tee")

  local selected=$(printf "%s\n" "${languages[@]}" "${commands[@]}" | fzf)
  if [[ -z $selected ]]; then
    return 0
  fi

  read -p "Enter Query: " query
  query=$(echo $query | tr ' ' '+')

  if printf "%s\n" "${languages[@]}" | grep -q "^$selected$"; then
    tmux neww bash -c "while :; do read -p 'Enter Query: ' query; [[ -z \$query ]] && break; query=\$(echo \$query | tr ' ' '+'); echo \"curl cht.sh/$selected/\$query/\"; curl cht.sh/$selected/\$query; done"
  else
    tmux neww bash -c "while :; do read -p 'Enter Query: ' query; [[ -z \$query ]] && break; query=\$(echo \$query | tr ' ' '+'); curl -s cht.sh/$selected~\$query | less; done"
  fi
}

# Search files and print content
pfc() {
  local depth=1
  local pattern="*"
  local log_file="pfc.log"

  local dir="$1"
  shift

  if [[ -z "$dir" ]]; then
    echo "Usage: pfc <directory> [-d depth] [-p pattern]" && return 1
  fi

  while getopts "d:p:" opt; do
    case $opt in
    d) depth="$OPTARG" ;;
    p) pattern="$OPTARG" ;;
    *) echo "Usage: pfc <directory> [-d depth] [-p pattern]" && return 1 ;;
    esac
  done

  log "Searching in directory: $dir with depth: $depth and pattern: $pattern" "$log_file"

  find "$dir" -maxdepth "$depth" -type f -name "$pattern" -exec echo -e "\n--- {} ---\n" \; -exec cat {} \; 2>>"$USER_LOG_DIR/$log_file"

  log "Completed searching in directory: $dir" "$log_file"
}

# Connect to SSH host
fssh() {
  log "Connecting to SSH host" "fssh.log"
  local host=$(grep "Host " ~/.ssh/config | awk '{print $2}' | fzf --exit-0)
  [ -n "$host" ] && ssh "$host"
}
