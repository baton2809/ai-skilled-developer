## Working with files

Before reading any file, check its size:
  wc -l <file>

If the file has >500 lines, read its structure first, not the whole file:
  # Python
  grep -n "^def \|^class \|^@" <file>
  # JS/TS
  grep -n "^function \|^const \|^class \|^export" <file>
  # Java
  grep -n "^public \|^private \|^protected \|^class \|^interface" <file>

Then read only the needed sections using offset + limit.
Never read a file whole if it has >800 lines.

## Before rewriting a file

1. List ALL units from the old file (functions / classes / routes)
2. Split into three columns: KEEP / REMOVE / ADD
3. Only after that write the new version

Violating this rule causes loss of code from the original.

## Context budgeting

For any "rewrite a large file" task:
1. AUDIT phase: read-only, no edits
   - Extract the structure of all files (grep)
   - Read all needed sections
   - Build the KEEP / REMOVE / ADD list
2. WRITE phase: only after the audit is complete

## Git workflow

- Make atomic commits (one logical unit per commit)
- Use Conventional Commits: feat:, fix:, refactor:, docs:, chore:
- Before committing, always verify nothing is broken: run tests / lint
- Never commit with --no-verify

## Security

- Never print the contents of .env, *_KEY, *_SECRET, *_TOKEN to stdout
- Never add secrets to git
- To check whether a variable exists use:
    grep -c "VARIABLE_NAME" .env
  Do NOT use cat or echo on these files
- Before running destructive commands (rm -rf, DROP, TRUNCATE) - always ask for confirmation

## On context compaction

Always preserve:
- List of changed files
- Current test status
- Architectural decisions made in this session
- Incomplete tasks
