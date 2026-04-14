#!/bin/bash
# Dual-purpose hook — behavior depends on HOOK_EVENT env var set by the caller,
# or detected from the JSON shape of stdin.
#
#   PostToolUse  (matcher: Read)    → appends file path to session read-log
#   SessionStart (matcher: compact) → injects read-log into stdout context
#
# State files live in ~/.claude/state/session-<id>-read-files.txt
# Files older than 7 days are cleaned up on every SessionStart invocation.

STATE_DIR="$HOME/.claude/state"
mkdir -p "$STATE_DIR"

INPUT=$(cat)

# Detect event type from JSON shape:
#   PostToolUse has .tool_result
#   SessionStart / compact trigger has no .tool_result and no .tool_input
TOOL_RESULT=$(echo "$INPUT" | jq -r '.tool_result // empty')
TOOL_INPUT=$(echo  "$INPUT" | jq -r '.tool_input  // empty')

# ── PostToolUse: record the file that was just read ──────────────────────────
if [ -n "$TOOL_RESULT" ] || [ -n "$TOOL_INPUT" ]; then
  SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
  FILE_PATH=$(echo  "$INPUT" | jq -r '.tool_input.file_path // empty')

  if [ -n "$FILE_PATH" ]; then
    STATE_FILE="$STATE_DIR/session-${SESSION_ID}-read-files.txt"
    # Only append if not already recorded
    if ! grep -qF "$FILE_PATH" "$STATE_FILE" 2>/dev/null; then
      echo "$FILE_PATH" >> "$STATE_FILE"
    fi
  fi
  exit 0
fi

# ── SessionStart (compact): inject read-log into context ─────────────────────
# Clean up state files older than 7 days
find "$STATE_DIR" -name "session-*-read-files.txt" -mtime +7 -delete 2>/dev/null

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
STATE_FILE="$STATE_DIR/session-${SESSION_ID}-read-files.txt"

if [ -f "$STATE_FILE" ] && [ -s "$STATE_FILE" ]; then
  echo ""
  echo "Files already read in this session (do not re-read unless changed):"
  while IFS= read -r line; do
    echo "  - $line"
  done < "$STATE_FILE"
  echo ""
fi

exit 0
