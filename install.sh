#!/bin/bash
# install.sh — sets up ~/.claude from this repo
# Safe to run multiple times (idempotent)

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR"

echo "Installing from: $REPO_DIR"
echo "Target:          $CLAUDE_DIR"
echo ""

# ── Symlinks: hooks / skills / agents ────────────────────────────────────────
# These stay in sync automatically after git pull
for dir in hooks skills agents; do
  TARGET="$CLAUDE_DIR/$dir"
  if [ -L "$TARGET" ]; then
    echo "  symlink exists: $TARGET"
  elif [ -d "$TARGET" ]; then
    echo "  WARNING: $TARGET is a plain directory — remove it manually to create a symlink"
  else
    ln -s "$REPO_DIR/$dir" "$TARGET"
    echo "  linked: $TARGET → $REPO_DIR/$dir"
  fi
done

# ── Copies: CLAUDE.md + settings.json ────────────────────────────────────────
# Copied, not symlinked — can be overridden locally without touching the repo
for file in CLAUDE.md settings.json; do
  DEST="$CLAUDE_DIR/$file"
  if [ -f "$DEST" ]; then
    echo "  exists (kept):  $DEST"
  else
    cp "$REPO_DIR/$file" "$DEST"
    echo "  copied: $DEST"
  fi
done

# ── Permissions ───────────────────────────────────────────────────────────────
chmod +x "$REPO_DIR"/hooks/*.sh

echo ""
echo "Done. Open Claude Code — hooks and skills are active."
echo ""
echo "To update after git pull:"
echo "  git pull  # symlinked dirs update automatically"
echo "  # CLAUDE.md and settings.json are copies — update manually if needed"
