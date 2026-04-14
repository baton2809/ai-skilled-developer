---
name: push
description: Push current branch to remote with safety checks. Use when user asks to push changes, sync with remote, or publish a branch.
allowed-tools: Bash(git *)
---

Push the current branch to remote:

1. Run `git branch --show-current` to confirm the active branch
2. Run `git status` to ensure the working tree is clean (no uncommitted changes)
3. Run `git log origin/<branch>..HEAD --oneline` to show commits that will be pushed
   - If this fails (no upstream set), run `git log HEAD --oneline -5`
4. If the branch is `main` or `master`:
   - Show a warning: "You are about to push directly to <branch>"
   - Ask the user for explicit confirmation before proceeding
5. After confirmation (or if branch is not main/master), run:
   `git push` (or `git push -u origin <branch>` if no upstream is set)
6. Show the result and the remote URL
