# AI-Skilled Developer: Claude Code Starter Kit

> Professional Claude Code setup for engineering teams transitioning to AI-assisted development.

A ready-to-use configuration that gives Claude Code context budgeting, **enforcing** safety hooks, auto-formatting, skills, and reusable agents — out of the box.

## What's inside

```
├── CLAUDE.md          ← Soft guidance loaded into every Claude session
├── settings.json      ← Model, permissions, env vars, and hook wiring
├── hooks/
│   ├── check-file-size.sh           ← BLOCKS reads of files >800 lines without offset+limit
│   ├── security-gate.sh             ← BLOCKS printing .env / destructive SQL (structural check)
│   ├── force-skill-for-side-effects.sh ← BLOCKS git commit/push, npm publish without skills
│   ├── session-state-tracker.sh     ← Tracks read files per session, injects after compaction
│   ├── todowrite-nudge.sh           ← Nudges TodoWrite on multi-step prompts
│   ├── auto-format.sh               ← Runs black/ruff/prettier after every write
│   ├── generate-commit-msg.sh       ← Suggests commit message via Ollama (optional)
│   └── log-summarizer.sh            ← Summarizes large .log files via Ollama (optional)
├── skills/
│   ├── commit/SKILL.md  ← /commit — staged diff → Conventional Commits message → approval
│   ├── push/SKILL.md    ← /push   — branch check → show commits → confirm on main/master
│   ├── release/SKILL.md ← /release — template for npm/pip publish workflow
│   └── deploy/SKILL.md  ← /deploy  — template for docker push workflow
├── agents/
│   ├── planner.md     ← Opus-powered architect: plan only, no code
│   └── reviewer.md    ← Sonnet-powered reviewer: Critical/Warning/Info report
└── guide/
    └── ai-developer-workflow-guide.md   ← Full lecture guide (RU)
```

## Install in 3 steps

```bash
# 1. Clone
git clone git@github.com:baton2809/ai-skilled-developer.git
cd ai-skilled-developer

# 2. Copy to your Claude config directory
cp CLAUDE.md ~/.claude/CLAUDE.md
cp settings.json ~/.claude/settings.json
cp -r hooks ~/.claude/hooks
cp -r agents ~/.claude/agents
cp -r skills ~/.claude/skills

# 3. Make hooks executable
chmod +x ~/.claude/hooks/*.sh
```

That's it. Open Claude Code — the rules and hooks are active immediately.

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

**`session-state-tracker.sh`** — tracks which files Claude has already read in a session (stored in `~/.claude/state/`). After context compaction, injects the list so Claude doesn't re-read unchanged files. State files older than 7 days are cleaned up automatically.

**`todowrite-nudge.sh`** — injects a reminder to use TodoWrite when a prompt is long (>200 chars), contains multiple items, or uses phrases like "implement all" / "finish everything". Always exits 0 — nudge only, never blocks.

**`auto-format.sh`** — runs formatters after every file write (if installed):
- `.py` → `black` + `ruff --fix`
- `.ts` / `.tsx` / `.js` / `.jsx` → `prettier`
- `.java` → `google-java-format`

**`generate-commit-msg.sh`** — suggests a commit message via `ollama run gemma3:4b` when Claude runs `git commit`. Optional: silently skips if Ollama is not running.

**`log-summarizer.sh`** — if a `.log` file exceeds 500 lines, runs `ollama run gemma3:4b` to produce a compact summary and blocks the raw read (`exit 2`). Optional: without Ollama the hook exits 0 and Claude reads the file normally.

### Skills

Skills are invoked with `/skill-name` and enforce a structured workflow with user approval gates.

**`/commit`** — shows staged diff, drafts a Conventional Commits message, asks for approval, then commits. Enforces `feat:` / `fix:` / `refactor:` / `docs:` / `chore:` prefixes and ≤72 char subject line.

**`/push`** — verifies current branch, shows commits to be pushed, requires explicit confirmation before pushing to `main` or `master`.

**`/release`** and **`/deploy`** — base templates. Customize for your registry and pipeline.

### Agents

**`planner`** (Opus) — receives a task description, reads the codebase structure, returns a numbered implementation plan. Never writes code.

**`reviewer`** (Sonnet) — receives a diff or file list, returns a structured report:
- **Critical** — security issues, data loss risk, broken logic
- **Warning** — issues to fix before merge
- **Info** — style notes, minor suggestions
- **Verdict** — `APPROVE` or `REQUEST CHANGES`

**Usage pattern:**
```
"Use the planner agent to plan: add pagination to the API"
  -> planner returns a numbered plan
"Implement this plan"
  -> main agent writes code
"Use the reviewer agent to review the changes"
  -> reviewer returns a structured report
```

## Customizing for your project

After installing globally, add a project-level `CLAUDE.md` in your repo root with:

```markdown
# Project: <name>

## Stack
- Backend: FastAPI / Python 3.12
- DB: PostgreSQL 16
- Infra: Docker Compose

## Key commands
- `make dev` — start in dev mode
- `make test` — run tests
- `make lint` — lint

## Project structure
src/api/     — FastAPI routers
src/services/ — business logic
tests/       — pytest tests

## Conventions
- All API responses use envelope: {data, error, meta}
- Logging: structlog, JSON format
```

Claude reads this instead of scanning thousands of lines of code.

Customize `/release` and `/deploy` skills for your actual registry and pipeline before using them.

## Requirements

- [Claude Code](https://claude.ai/code) CLI installed
- macOS (for `osascript` notifications — edit or remove that hook on Linux)
- `jq` — used by all hook scripts (`brew install jq`)
- Optional: `black`, `ruff`, `prettier` for auto-formatting
- Optional: [Ollama](https://ollama.com) + `gemma3:4b` for log summarization and commit message suggestions

## Read more

Full guide with architecture diagrams, Ollama integration, skill creation, and team rollout checklist: [`guide/ai-developer-workflow-guide.md`](guide/ai-developer-workflow-guide.md)

---

*Artsiom Butomau — Principal Software Engineer, AI/ML*
*Telegram: [@devdeaf](https://t.me/devdeaf)*
