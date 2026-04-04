#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_result.tool_use_id // empty')
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

case "$FILE" in
  *.py)
    command -v black >/dev/null 2>&1 && black -q "$FILE" 2>/dev/null
    command -v ruff >/dev/null 2>&1 && ruff check --fix -q "$FILE" 2>/dev/null
    ;;
  *.ts|*.tsx|*.js|*.jsx)
    command -v prettier >/dev/null 2>&1 && prettier --write "$FILE" 2>/dev/null
    ;;
  *.java)
    command -v google-java-format >/dev/null 2>&1 && google-java-format -i "$FILE" 2>/dev/null
    ;;
esac

exit 0
