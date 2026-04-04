#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Block printing secret files
if echo "$COMMAND" | grep -qiE '(cat|echo|print).*\.(env|pem|key)'; then
  echo "BLOCKED: potential secret output detected. Use grep -c to check for key presence, do not print the value." >&2
  exit 2
fi

# Block destructive SQL
if echo "$COMMAND" | grep -qiE '(DROP|TRUNCATE|DELETE FROM) '; then
  echo "BLOCKED: destructive SQL operation. Confirm necessity before proceeding." >&2
  exit 2
fi

exit 0
