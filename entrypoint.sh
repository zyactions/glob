#!/usr/bin/env bash

set -e
set -o noglob

# This function shell-quotes the argument $1
quote()
{
    local quoted=${1//\'/\'\\\'\'}
    printf "'%s'" "$quoted"
}

# This function sets the GitHub Action output $1 to the value $2
output()
{
  if [[ -z "$GITHUB_OUTPUT" ]]; then
    echo "::set-output name=$1::$2"
  else
    echo "$1=$2" >> "$GITHUB_OUTPUT"
  fi
}

# This functions emits the warning $1 to the GitHub Action output
warn()
{
  echo "::warning ::$1"
}

# This functions emits the error $1 to the GitHub Action output and exits the script
fatal()
{
  echo "::error ::$1"
  exit 1
}

# Build base command

if [[ -n "$INPUT_VALUES" ]]; then
  # Filter the input values
  cmd="python3 '$GITHUB_ACTION_PATH/glob/globmatch.py'"
else
  # Operate on the live file system
  cmd="python3 '$GITHUB_ACTION_PATH/glob/glob.py'"
fi

if [[ "$INPUT_SHELL_OUTPUT" != "false" ]]; then
  cmd="$cmd --shell-output"
fi

patterns=""
while IFS= read -r line
do
  quoted=$(quote "$line")
  patterns="$patterns $quoted"
done < <(printf '%s\n' "$INPUT_PATTERN")

cmd="$cmd$patterns"

# Execute directly

if [[ -z "$INPUT_RETURN_PROMISE" ]]; then
  if [[ "$INPUT_VALUES" == '-' ]]; then
    input="$INPUT_DATA_SOURCE"
  else
    input="echo $INPUT_VALUES"
  fi

  echo "$input" | eval "$cmd"
  exit 0
fi

# Build promise

if [[ "$INPUT_VALUES" == '-' ]] && [[ -n "$INPUT_DATA_SOURCE" ]]; then
  input="$INPUT_DATA_SOURCE"
else
  # Transform newline delimited input values to shell-quoted arguments
  input="echo "
  while IFS= read -r line
  do
    quoted=$(quote "$line")
    input="$input$quoted$'\n'"
  done < <(printf '%s\n' "$INPUT_VALUES")
fi

cmd="$input | $cmd"

output "promise" "$cmd"
