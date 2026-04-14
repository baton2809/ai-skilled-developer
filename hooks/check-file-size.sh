#!/bin/bash
# PreToolUse: Read
# Blocks whole-file reads on files >800 lines unless offset+limit are both provided.

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

LINES=$(wc -l < "$FILE" 2>/dev/null || echo 0)

if [ "$LINES" -le 800 ]; then
  exit 0
fi

# File is large — check if caller supplied explicit offset AND limit
OFFSET=$(echo "$INPUT" | jq -r '.tool_input.offset // empty')
LIMIT=$(echo  "$INPUT" | jq -r '.tool_input.limit  // empty')

if [ -n "$OFFSET" ] && [ -n "$LIMIT" ]; then
  # Caller is being specific — allow
  exit 0
fi

# Determine language hint for the grep command suggestion
GREP_PATTERN=""
case "$FILE" in
  *.py)   GREP_PATTERN="'^def \\|^class \\|^@'" ;;
  *.ts|*.tsx|*.js|*.jsx) GREP_PATTERN="'^function \\|^const \\|^class \\|^export '" ;;
  *.java) GREP_PATTERN="'^public \\|^private \\|^protected \\|^class \\|^interface '" ;;
  *)      GREP_PATTERN="'^def \\|^class \\|^function \\|^const \\|^export '" ;;
esac

cat >&2 <<EOF
BLOCKED: file has $LINES lines — reading it whole wastes context and violates CLAUDE.md rules.

Map structure first:
  grep -n $GREP_PATTERN $FILE

Then Read with explicit offset and limit for the sections you actually need:
  offset=<start_line> limit=<num_lines>

If the file is genuinely flat/data (CSV, JSON, log), use Grep to extract relevant lines instead.
EOF

exit 2
