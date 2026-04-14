#!/bin/bash
# PreToolUse: Bash
# Blocks genuinely dangerous commands using structural analysis via jq.
# Does NOT block on commit messages, grep patterns, or arbitrary text content.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# ── 1. Secret file exposure ───────────────────────────────────────────────────
# Block: cat / less / head / tail on .env, *.pem, *.key, *.token files
# Match: command starts with (or pipes through) cat/less/head/tail AND target looks like a secret file
# NOT blocked: grep -c KEY .env  (presence check — safe)
if echo "$COMMAND" | grep -qE '^\s*(cat|less|head|tail)\s' || \
   echo "$COMMAND" | grep -qE '\|\s*(cat|less|head|tail)\s'; then
  if echo "$COMMAND" | grep -qE '\.(env|pem|key|token|secret)(\s|$|")'; then
    cat >&2 <<EOF
BLOCKED: printing secret file contents.
  Detected: $COMMAND

To check whether a variable exists use:
  grep -c "VARIABLE_NAME" .env
Do NOT print the file — it may contain credentials.
EOF
    exit 2
  fi
fi

# ── 2. Destructive SQL — only when invoked through a DB CLI ──────────────────
# Block: psql/mysql/sqlite3 ... DROP TABLE | TRUNCATE | DELETE FROM
# NOT blocked: git commit -m "drop old cache", grep DROP file.sql, etc.
FIRST_TOKEN=$(echo "$COMMAND" | awk '{print $1}' | xargs basename 2>/dev/null)
if echo "$FIRST_TOKEN" | grep -qE '^(psql|mysql|sqlite3|mariadb|cockroach)$'; then
  if echo "$COMMAND" | grep -qiE '\b(DROP\s+TABLE|TRUNCATE\s+TABLE|DELETE\s+FROM)\b'; then
    cat >&2 <<EOF
BLOCKED: destructive SQL operation via $FIRST_TOKEN.
  Detected: $COMMAND

Confirm the target database and table before proceeding.
Ask user for explicit approval, then re-run manually if confirmed.
EOF
    exit 2
  fi
fi

# ── 3. Pipe-to-shell (curl|sh, wget|sh) ─────────────────────────────────────
# Note: also covered by permissions.deny, this is a belt-and-suspenders check.
if echo "$COMMAND" | grep -qE '(curl|wget)\s[^|]+\|\s*(bash|sh|zsh)\b'; then
  cat >&2 <<EOF
BLOCKED: pipe-to-shell pattern detected.
  Detected: $COMMAND

Download the script first, inspect it, then run explicitly:
  curl -O <url> && cat <script.sh> && bash <script.sh>
EOF
  exit 2
fi

# ── 4. rm -rf on root / home anchors ────────────────────────────────────────
# Note: / and ~ variants are also in permissions.deny.
# Add $HOME and .. variants that permissions.deny may miss.
if echo "$COMMAND" | grep -qE 'rm\s+-[a-zA-Z]*rf[a-zA-Z]*\s+(\/|~|\$HOME|\.\.)(\s|$)'; then
  cat >&2 <<EOF
BLOCKED: rm -rf on a root-level path.
  Detected: $COMMAND

Specify an explicit subdirectory path, not a root anchor.
EOF
  exit 2
fi

exit 0
