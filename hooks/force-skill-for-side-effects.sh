#!/bin/bash
# PreToolUse: Bash
# Forces the use of dedicated skills for high-consequence side-effect commands.
# This prevents Claude from bypassing skill workflows (review, approval, logging).

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Check only the first line — the actual command verb is always there.
# Subsequent lines are arguments (e.g. commit message body) and must not be matched.
NORMALIZED=$(echo "$COMMAND" | head -1 | sed 's/  */ /g' | sed 's/^ //')

# ── 1. git commit ────────────────────────────────────────────────────────────
if echo "$NORMALIZED" | grep -qE '^\s*git\s+commit\b'; then
  cat >&2 <<EOF
BLOCKED: direct git commit is not allowed.

Use the /commit skill instead:
  /commit

The skill will: show staged diff, draft a Conventional Commits message,
ask for approval, then commit. This ensures atomic commits with proper messages.
EOF
  exit 2
fi

# ── 2. git push to main/master ───────────────────────────────────────────────
if echo "$NORMALIZED" | grep -qE '^\s*git\s+push\b'; then
  if echo "$NORMALIZED" | grep -qE '\b(main|master)\b'; then
    cat >&2 <<EOF
BLOCKED: direct git push to main/master is not allowed.

Use the /push skill instead:
  /push

The skill will: verify current branch, show what will be pushed,
and require explicit confirmation before pushing to a protected branch.
EOF
    exit 2
  fi
fi

# ── 3. npm publish / pip publish / twine upload ──────────────────────────────
if echo "$NORMALIZED" | grep -qE '^\s*(npm\s+publish|pip\s+publish|twine\s+upload)\b'; then
  cat >&2 <<EOF
BLOCKED: direct package publish is not allowed.

Use the /release skill instead:
  /release

The skill will: run pre-publish checks, confirm the version, and publish.
EOF
  exit 2
fi

# ── 4. docker push ───────────────────────────────────────────────────────────
if echo "$NORMALIZED" | grep -qE '^\s*docker\s+push\b'; then
  cat >&2 <<EOF
BLOCKED: direct docker push is not allowed.

Use the /deploy skill instead:
  /deploy

The skill will: verify the image tag, confirm the registry target, and push.
EOF
  exit 2
fi

exit 0
