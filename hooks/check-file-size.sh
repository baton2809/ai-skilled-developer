#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

LINES=$(wc -l < "$FILE" 2>/dev/null || echo 0)

if [ "$LINES" -gt 500 ]; then
  echo "WARNING: $FILE has $LINES lines. Consider using grep to find structure first, then read specific sections with offset/limit." >&2
fi

exit 0
