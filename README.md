# AI-Skilled Developer: Claude Code Starter Kit

> Professional Claude Code setup for engineering teams transitioning to AI-assisted development.

A ready-to-use configuration that gives Claude Code context budgeting, safety hooks, auto-formatting, and reusable agents — out of the box.

## What's inside

```
├── CLAUDE.md          ← Global rules loaded into every Claude session
├── settings.json      ← Model, permissions, env vars, and hook wiring
├── hooks/
│   ├── check-file-size.sh   ← Warns before reading large files (>500 lines)
│   ├── security-gate.sh     ← Blocks printing .env / destructive SQL
│   ├── auto-format.sh       ← Runs black/ruff/prettier after every write
│   └── log-summarizer.sh    ← Summarizes large .log files via Ollama
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

# 3. Make hooks executable
chmod +x ~/.claude/hooks/*.sh
```

That's it. Open Claude Code — the rules and hooks are active immediately.

## What each part does

### CLAUDE.md — rules loaded in every session

- **File size check**: before reading, run `wc -l`. If >500 lines — grep structure first, then read sections.
- **Rewrite discipline**: list all units (KEEP / REMOVE / ADD) before touching a file.
- **Context budgeting**: AUDIT phase (read-only) then WRITE phase — never mix them.
- **Git**: atomic commits, Conventional Commits (`feat:` / `fix:` / `refactor:` / `docs:` / `chore:`), no `--no-verify`.
- **Secrets**: never print `.env` / `*.key` — use `grep -c VARIABLE_NAME .env` to check presence only.
- **On compaction**: Claude preserves the list of changed files, test status, and open tasks.

### settings.json — hook wiring and permissions

| Hook | Trigger | Effect |
|------|---------|--------|
| `Notification` | Claude waits for input | macOS notification via `osascript` |
| `PreToolUse: Read` | Before reading any file | `check-file-size.sh` + `log-summarizer.sh` |
| `PreToolUse: Bash` | Before any shell command | `security-gate.sh` |
| `PostToolUse: Write/Edit` | After writing a file | `auto-format.sh` |
| `SessionStart: compact` | After context compaction | Reminder to verify task state |

Context compaction starts at 50% (`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=50`) instead of the default 95% — prevents Claude from forgetting early instructions.

### Hooks

**`check-file-size.sh`** — advisory warning on stderr if a file exceeds 500 lines. Always exits 0, never blocks.

**`security-gate.sh`** — hard block (`exit 2`) if a Bash command tries to print `.env` / `.pem` / `.key` files, or runs `DROP` / `TRUNCATE` / `DELETE FROM` SQL without confirmation.

**`auto-format.sh`** — runs formatters after every file write (if installed):
- `.py` → `black` + `ruff --fix`
- `.ts` / `.tsx` / `.js` / `.jsx` → `prettier`
- `.java` → `google-java-format`

**`log-summarizer.sh`** — if a `.log` file exceeds 500 lines, runs `ollama run mistral` to produce a compact summary and blocks the raw read (`exit 2`). Requires [Ollama](https://ollama.com) with `mistral` pulled. Without Ollama, the hook exits 0 and Claude reads the file normally.

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

## Requirements

- [Claude Code](https://claude.ai/code) CLI installed
- macOS (for `osascript` notifications — edit or remove that hook on Linux)
- `jq` — used by hook scripts (`brew install jq`)
- Optional: `black`, `ruff`, `prettier` for auto-formatting
- Optional: [Ollama](https://ollama.com) + `mistral` for log summarization

## Read more

Full guide with architecture diagrams, Ollama integration, skill creation, and team rollout checklist: [`guide/ai-developer-workflow-guide.md`](guide/ai-developer-workflow-guide.md)

---

*Artsiom Butomau — Principal Software Engineer, AI/ML*
*Telegram: [@devdeaf](https://t.me/devdeaf)*
