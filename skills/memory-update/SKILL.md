---
name: memory-update
description: Update MEMORY.md in the current project root. Use at session start, after context compaction, when switching tasks, or every ~45 minutes.
allowed-tools: Bash(git *)
---

Update MEMORY.md in the current project root:

1. Read the current MEMORY.md if it exists
2. Run `git branch --show-current` and `git status --short`
3. Write (or overwrite) MEMORY.md with the following structure:

```markdown
## current state
branch: <branch>
in progress: <what is being worked on now>
broken: <what is currently broken or blocked>

## active decisions
<architectural or technical decisions made in this session — why X was chosen over Y>

## constraints
<project-specific constraints with rationale, e.g. "kopecks in DB always (float precision)">

## open questions
<unresolved questions, things to discuss>

## next step
<the single concrete next action>
```

Rules:
- Do NOT delete existing sections — update them
- Keep each section concise (1-5 bullet points)
- Rationale ("why") is more valuable than just the fact
