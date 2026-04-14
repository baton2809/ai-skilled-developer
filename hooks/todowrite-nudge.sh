#!/bin/bash
# UserPromptSubmit
# Nudges Claude to use TodoWrite for multi-step or complex prompts.
# Always exits 0 — this is guidance, not a block.

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

if [ -z "$PROMPT" ]; then
  exit 0
fi

SHOULD_NUDGE=0

# ── Trigger 1: prompt is long (>200 chars) ───────────────────────────────────
LENGTH=${#PROMPT}
if [ "$LENGTH" -gt 200 ]; then
  SHOULD_NUDGE=1
fi

# ── Trigger 2: plural task language (RU + EN) ────────────────────────────────
if echo "$PROMPT" | grep -qiE '(исправь баги|добавь фичи|fix bugs|add features|fix issues)'; then
  SHOULD_NUDGE=1
fi

# ── Trigger 3: enumeration — comma-separated list of 3+ items ───────────────
# Count commas: 2+ commas → likely 3+ items
COMMA_COUNT=$(echo "$PROMPT" | tr -cd ',' | wc -c)
if [ "$COMMA_COUNT" -ge 2 ]; then
  SHOULD_NUDGE=1
fi

# ── Trigger 4: numbered list (1. ... 2. ... or 1) ... 2) ...) ────────────────
if echo "$PROMPT" | grep -qE '^\s*[0-9]+[.)]\s' || echo "$PROMPT" | grep -qE '\n\s*[0-9]+[.)]\s'; then
  SHOULD_NUDGE=1
fi

# ── Trigger 5: explicit multi-task phrases (RU + EN) ─────────────────────────
if echo "$PROMPT" | grep -qiE '(реализуй|сделай всё|доведи до конца|implement all|do everything|complete all|finish everything)'; then
  SHOULD_NUDGE=1
fi

if [ "$SHOULD_NUDGE" -eq 1 ]; then
  echo "This looks like a multi-step task. Start with TodoWrite to track progress — it survives context compaction and prevents losing track of subtasks."
fi

exit 0
