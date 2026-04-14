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
- Before committing, always verify nothing is broken: run tests / lint
- Never commit with --no-verify
- NEVER add `Co-Authored-By:` lines to commit messages

## Security

- Never add secrets to git
- To check whether a variable exists use:
    grep -c "VARIABLE_NAME" .env
  Do NOT cat or echo secret files

## On context compaction

Always preserve:
- List of changed files
- Current test status
- Architectural decisions made in this session
- Incomplete tasks
