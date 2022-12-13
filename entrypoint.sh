#!/usr/bin/env bash

set -e

# Input checks

if [[ -n "$INPUT_VALUES" ]] && [[ -n "$INPUT_PIPE" ]]; then
  echo "::error ::The 'values' input must be mutually exclusive with the 'pipe' input."
  exit 1
fi

# Build base command

if [[ -n "$INPUT_VALUES" ]] || [[ -n "$INPUT_PIPE" ]]; then
  # Filter the given input values
  cmd="python3 '$GITHUB_ACTION_PATH/glob/globmatch.py'"
else
  # Operate on the live file system
  cmd="python3 '$GITHUB_ACTION_PATH/glob/glob.py'"
fi

patterns=$(printf '%s\n' "$INPUT_PATTERN" | "$GITHUB_ACTION_PATH/quote.sh" ' ')
cmd+=" $patterns"

if [[ "$RUNNER_OS" == "Windows" ]]; then
  # Remove carriage return from Python output
  cmd+=" | sed $'s/\r$//'"
fi

if [[ "$INPUT_SORT" == "true" ]]; then
  cmd+=" | LC_ALL=C sort -u"
fi

if [[ "$INPUT_QUOTE" == "true" ]]; then
  cmd+=" | '$GITHUB_ACTION_PATH/quote.sh' ' '"
fi

# Execute directly

if [[ "$INPUT_RETURN_PIPE" != "true" ]]; then
  if [[ -n "$INPUT_PIPE" ]]; then
    cmd="$INPUT_PIPE | $cmd"
  else
    cmd="echo \"$INPUT_VALUES\" | $cmd"
  fi

  matches=$(eval "$cmd")

  eof=$(openssl rand -hex 16)
  # echo "matches<<$eof$matches$eof" >> $GITHUB_OUTPUT
  echo "matches<<$eof" >> $GITHUB_OUTPUT
  echo "$matches" >> $GITHUB_OUTPUT
  echo "$eof" >> $GITHUB_OUTPUT
  exit 0
fi

# Build output "pipe" command

if [[ -n "$INPUT_PIPE" ]]; then
  input="$INPUT_PIPE"
else
  # Transform newline separated values into a shell-quoted string
  input=$(printf '%s\n' "$INPUT_VALUES" | "$GITHUB_ACTION_PATH/quote.sh" '$'"'"'\\n'"'"'')
  input="echo $input"
fi

cmd="$input | $cmd"
echo "pipe=$cmd" >> "$GITHUB_OUTPUT"
