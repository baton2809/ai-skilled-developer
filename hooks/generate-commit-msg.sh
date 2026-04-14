#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Срабатывает только на git commit
if echo "$COMMAND" | grep -q "git commit"; then
  DIFF=$(git diff --cached --stat 2>/dev/null)
  if [ -n "$DIFF" ]; then
    SUGGESTED=$(echo "$DIFF" | ollama run gemma3:4b \
      "Generate a conventional commit message (feat/fix/refactor/docs/chore) for this diff. One line, max 72 chars. Only the message, nothing else." 2>/dev/null)
    echo "💡 Suggested commit message: $SUGGESTED"
  fi
fi

exit 0
