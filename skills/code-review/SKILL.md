---
name: code-review
description: Run a code review on current changes. Use before committing or after a significant implementation to get a structured Critical/Warning/Info report.
allowed-tools: Bash(git *)
---

Run a code review on current changes:

1. Run `git diff HEAD` to get the full diff of uncommitted changes
2. If the diff is empty, run `git diff HEAD~1` to review the last commit
   - If still empty, ask the user to specify a file or commit range
3. Pass the diff to the reviewer agent:
   - Use the Agent tool with subagent_type=reviewer
   - Prompt: "Review this diff:\n<diff>"
4. Return the structured report as-is:
   - **Critical** — security issues, data loss risk, broken logic
   - **Warning** — issues to fix before merge
   - **Info** — style notes, minor suggestions
   - **Verdict** — APPROVE or REQUEST CHANGES
