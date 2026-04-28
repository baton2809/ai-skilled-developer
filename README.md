# AI-Skilled Developer: Claude Code Starter Kit

> Professional Claude Code setup for engineering teams transitioning to AI-assisted development.

A ready-to-use configuration that gives Claude Code context budgeting, **enforcing** safety hooks, auto-formatting, skills, and reusable agents — out of the box.

## What's inside

```
├── CLAUDE.md          ← Soft guidance loaded into every Claude session
├── settings.json      ← Model, permissions, env vars, and hook wiring
├── hooks/
│   ├── check-file-size.sh              ← BLOCKS reads of files >800 lines without offset+limit
│   ├── security-gate.sh                ← BLOCKS printing .env / destructive SQL (structural check)
│   ├── force-skill-for-side-effects.sh ← BLOCKS git commit/push, npm publish without skills
│   ├── auto-format.sh                  ← Runs black/ruff/prettier after every write
│   ├── session-state-tracker.sh        ← Tracks read files per session, injects after compaction [advanced]
│   ├── todowrite-nudge.sh              ← Nudges TodoWrite on multi-step prompts [optional]
│   ├── generate-commit-msg.sh          ← Suggests commit message via Ollama [optional, requires Ollama]
│   └── log-summarizer.sh               ← Summarizes large .log files via Ollama [optional, requires Ollama]
├── skills/
│   ├── commit/SKILL.md        ← /commit       — staged diff → Conventional Commits message → approval
│   ├── push/SKILL.md          ← /push         — branch check → show commits → confirm on main/master
│   ├── code-review/SKILL.md   ← /code-review  — run reviewer agent on current git diff
│   ├── memory-update/SKILL.md ← /memory-update — update MEMORY.md in project root
│   ├── release/SKILL.md       ← /release — template for npm/pip publish workflow
│   └── deploy/SKILL.md        ← /deploy  — template for docker push workflow
├── agents/
│   ├── planner.md        ← Opus-powered architect: plan only, no code
│   ├── reviewer.md       ← Sonnet-powered reviewer: Critical/Warning/Info report
│   └── log-summarizer.md ← Summarizes docker logs / .log files via local Ollama
├── templates/
│   └── project/.claude/
│       ├── CLAUDE.md  ← Per-project context template (stack, conventions, danger zone)
│       └── MEMORY.md  ← Per-project session state template
└── guide/
    └── ai-developer-workflow-guide.md   ← Full lecture guide (RU)
```

## Install

```bash
git clone git@github.com:baton2809/ai-skilled-developer.git
cd ai-skilled-developer
./install.sh
```

`install.sh` creates symlinks for `hooks/`, `skills/`, `agents/` — so `git pull` updates them everywhere automatically. `CLAUDE.md` and `settings.json` are copied (not symlinked) so you can override them locally without touching the repo.

To update later:

```bash
git pull  # symlinked dirs pick it up immediately
```

## What each part does

### CLAUDE.md — soft guidance in every session

Contains only rules that cannot be deterministically enforced:
- **Rewrite discipline**: list all units (KEEP / REMOVE / ADD) before touching a file.
- **Context budgeting**: AUDIT phase (read-only) then WRITE phase — never mix them.
- **Git**: atomic commits, no `--no-verify`, no `Co-Authored-By` in commit messages.
- **Secrets**: use `grep -c VARIABLE_NAME .env` to check presence only.
- **On compaction**: Claude preserves the list of changed files, test status, and open tasks.

Rules that are enforced by hooks (file size limits, secret printing, Conventional Commits) have been removed from CLAUDE.md — they live in hooks now.

### settings.json — hook wiring and permissions

| Hook | Trigger | Effect |
|------|---------|--------|
| `Notification` | Claude waits for input | macOS notification via `osascript` |
| `Stop` | Claude finishes a task | macOS notification via `osascript` |
| `UserPromptSubmit` | Every user message | `todowrite-nudge.sh` — nudge on multi-step prompts |
| `PreToolUse: Read` | Before reading any file | `check-file-size.sh` + `log-summarizer.sh` + `session-state-tracker.sh` |
| `PreToolUse: Bash` | Before any shell command | `security-gate.sh` + `force-skill-for-side-effects.sh` + `generate-commit-msg.sh` |
| `PostToolUse: Write/Edit` | After writing a file | `auto-format.sh` |
| `PostToolUse: Read` | After reading any file | `session-state-tracker.sh` — records file to session log |
| `SessionStart: compact` | After context compaction | `session-state-tracker.sh` — injects list of already-read files |

Context compaction starts at 50% (`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=50`) instead of the default 95% — prevents Claude from forgetting early instructions.

### Hooks

**`check-file-size.sh`** — **enforcing** (`exit 2`) if a file exceeds 800 lines and neither `offset` nor `limit` is provided. Forces Claude to map structure with Grep first. If both params are present, passes through.

**`security-gate.sh`** — **enforcing** (`exit 2`) using structural analysis via jq:
- `cat` / `less` / `head` / `tail` on `.env`, `.pem`, `.key`, `.token` files
- `DROP TABLE` / `TRUNCATE` / `DELETE FROM` when invoked through `psql` / `mysql` / `sqlite3`
- Pipe-to-shell (`curl url | bash`)
- `rm -rf` on root/home anchors

Does **not** block: git commit messages containing "drop", grep patterns, arbitrary text.

**`force-skill-for-side-effects.sh`** — **enforcing** (`exit 2`) for high-consequence commands that must go through skill workflows:
- `git commit` → use `/commit`
- `git push origin main/master` → use `/push`
- `npm publish` / `pip publish` / `twine upload` → use `/release`
- `docker push` → use `/deploy`

**`auto-format.sh`** — runs formatters after every file write (if installed):
- `.py` → `black` + `ruff --fix`
- `.ts` / `.tsx` / `.js` / `.jsx` → `prettier`
- `.java` → `google-java-format`

**`session-state-tracker.sh`** *(advanced)* — tracks which files Claude has already read in a session (stored in `~/.claude/state/`). After context compaction, injects the list so Claude doesn't re-read unchanged files. State files older than 7 days are cleaned up automatically.

**`todowrite-nudge.sh`** *(optional)* — injects a reminder to use TodoWrite when a prompt is long (>200 chars), contains multiple items, or uses phrases like "implement all" / "finish everything". Always exits 0 — nudge only, never blocks.

**`generate-commit-msg.sh`** *(optional, requires Ollama)* — suggests a commit message via `ollama run qwen2.5-coder:14b` when Claude runs `git commit`. Silently skips if Ollama is not running.

**`log-summarizer.sh`** *(optional, requires Ollama)* — if a `.log` file exceeds 500 lines, runs `ollama run qwen2.5-coder:14b` to produce a compact summary and blocks the raw read (`exit 2`). Without Ollama the hook exits 0 and Claude reads the file normally.

### Skills

Skills are invoked with `/skill-name` and enforce a structured workflow with user approval gates.

**`/commit`** — shows staged diff, drafts a Conventional Commits message, asks for approval, then commits. Enforces `feat:` / `fix:` / `refactor:` / `docs:` / `chore:` prefixes and ≤72 char subject line.

**`/push`** — verifies current branch, shows commits to be pushed, requires explicit confirmation before pushing to `main` or `master`.

**`/code-review`** — runs the reviewer agent on `git diff HEAD` and returns a structured Critical / Warning / Info report.

**`/memory-update`** — creates or updates `MEMORY.md` in the project root with current branch, in-progress work, decisions, constraints, and next step. Use at session start and after context compaction.

**`/release`** and **`/deploy`** — base templates. Customize for your registry and pipeline.

### Agents

**`planner`** (Opus) — receives a task description, reads the codebase structure, returns a numbered implementation plan. Never writes code.

**`reviewer`** (Sonnet) — receives a diff or file list, returns a structured report:
- **Critical** — security issues, data loss risk, broken logic
- **Warning** — issues to fix before merge
- **Info** — style notes, minor suggestions
- **Verdict** — `APPROVE` or `REQUEST CHANGES`

**`log-summarizer`** (Sonnet) — receives a container name or log file path, reads the last 200 lines, summarizes via local Ollama (`qwen2.5-coder:14b`), returns ERRORS / WARNINGS / KEY EVENTS.

**Usage pattern:**
```
"Use the planner agent to plan: add pagination to the API"
  -> planner returns a numbered plan
"Implement this plan"
  -> main agent writes code
"Use the reviewer agent to review the changes"
  -> reviewer returns a structured report
```

## Per-project setup

### New project

```bash
# 1. Copy the template
cp -r /path/to/ai-skilled-developer/templates/project/.claude ./
cat templates/project/.gitignore >> .gitignore   # keep MEMORY.md out of git

# 2. Fill in .claude/CLAUDE.md — stack, conventions, danger zone
# 3. Extend .claude/settings.json — add stack-specific permissions
# 4. Open Claude Code → /memory-update
```

### `.claude/CLAUDE.md` — project context

Fill once, update rarely. Claude reads this instead of scanning thousands of lines of code:

```markdown
# Project: GEOLayer

## Stack
- Backend: Spring Boot 3 / Java 21
- DB: PostgreSQL 16
- Infra: Docker Compose

## Key commands
make dev     # start in dev mode
make test    # run tests
make lint    # checkstyle + spotbugs

## Domain vocabulary
kopecks — monetary amounts stored as Int in DB, returned as rubles in API
tariff  — subscription plan with pricing tiers

## Danger zone
Ask before any DELETE/TRUNCATE — payments table has live transactions
```

### `.claude/settings.json` — stack-specific permissions

Extends the global permissions. Add what your stack needs:

```json
{
  "permissions": {
    "allow": [
      "Bash(mvn *)",
      "Bash(make *)",
      "Bash(docker compose *)"
    ]
  }
}
```

### `.claude/MEMORY.md` — session state

Updated via `/memory-update`. Never committed (added to `.gitignore` by the template):

```markdown
## current state
branch: feature/trial-flow
in progress: trial expiry logic in SubscriptionService
broken: nothing

## active decisions
CloudPayments over YuKassa — existing contract, already integrated

## constraints
kopecks in DB always (float precision — learned the hard way)
no direct DB access from controllers (compliance audit requirement)

## next step
add TrialExpiredEvent handler in NotificationService
```

Claude without `MEMORY.md` starts cold every session. 15 minutes at the start beats re-explaining the domain from scratch.

## Requirements

- [Claude Code](https://claude.ai/code) CLI installed
- macOS (for `osascript` notifications — edit or remove that hook on Linux)
- `jq` — used by all hook scripts (`brew install jq`)
- Optional: `black`, `ruff`, `prettier` for auto-formatting
- Optional: [Ollama](https://ollama.com) + `qwen2.5-coder:14b` for log summarization and commit message suggestions

## Read more

Full guide with architecture diagrams, Ollama integration, skill creation, and team rollout checklist: [`guide/ai-developer-workflow-guide.md`](guide/ai-developer-workflow-guide.md)

---

*Artsiom Butomau — Principal Software Engineer, AI/ML*
*Telegram: [@devdeaf](https://t.me/devdeaf)*
