#!/bin/bash

update_my_repos() {
  local paths=(
    "$HOME/work/essencial/repos"
    "$HOME/work/syniti/repos"
    "$HOME/personal/projects"
    "$HOME/personal/sandbox"
  )

  for path in "${paths[@]}"; do
    log "Updating repositories in $path" "update_my_repos.log"
    update_repos "$path"
  done
}
