#!/bin/bash

# copy last command
clc() {
  if [[ -z "$1" ]]; then
    # Use the `fc` command to get the last command and re-execute it, capturing the output
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
