---
name: commit
description: Create a git commit following project conventions. Use when user asks to commit changes, save progress, or after completing a logical unit of work.
allowed-tools: Bash(git *)
---

Create a git commit:

1. Run `git status` to see the working tree state
2. Run `git diff --cached` to see what is staged
3. If nothing is staged:
   - Run `git diff --stat` to show unstaged changes
   - Ask the user which files to stage, then run `git add <files>`
4. Analyze the staged changes and write a Conventional Commits message:
   - `feat:` new functionality visible to the user
   - `fix:` bug fix
   - `refactor:` restructure without behavior change
   - `docs:` documentation only
   - `chore:` tooling, deps, config, CI
   - Keep the subject line ≤72 chars
   - NEVER add `Co-Authored-By:` lines
5. Show the proposed commit message to the user and ask for approval
6. After approval, run: `git commit -m "<message>"`
7. Run `git log -1 --oneline` to confirm the commit
