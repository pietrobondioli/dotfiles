#!/bin/bash

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
