#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ "$FILE" == *.log ]] && [ -f "$FILE" ]; then
  LINES=$(wc -l < "$FILE")
  if [ "$LINES" -gt 500 ]; then
    echo "=== LOG SUMMARY (local model, $LINES lines) ==="
    tail -n 500 "$FILE" | ollama run qwen2.5-coder:14b \
      "Summarize these logs concisely: errors, warnings, key events. JSON format." 2>/dev/null
    echo "=== END SUMMARY, original file too large to read directly ==="
    exit 2
  fi
fi

exit 0
