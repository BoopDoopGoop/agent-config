---
name: bootstrap-agents-md
description: Read the project and generate a project-level AGENTS.md
---

Read the project yourself — do not delegate to an external CLI.

Steps:
1. Run `ls -R . | head -80` to get the folder structure.
2. Read `pyproject.toml` or `package.json` (whichever exists), `README.md`, and a sample of source files to understand commands and code style.
3. Write `AGENTS.md` using the structure below. Keep the whole file under 150 lines. Instructions only, no explanations.

```
## About
(2-3 sentences: what this project is, what it does, who uses it)

## Critical Rules
(leave as placeholder — user fills in reactively as agent makes mistakes)

## Commands
- Package manager: (detect from lockfile — pnpm/npm/yarn/bun/uv)
- Dev server:
- Type check:
- Lint:
- Tests:
- Build:

## Architecture
(10 lines max — main folders, how they connect, entry points)

## Code Style
(specific rules from actual files only — not vague.
e.g. "always curly braces", "fetch not axios", "named exports only",
"no arrow functions at top level", "object params for 3+ args")

## Git
- Atomic commits, one logical change per commit
- Single-line commit messages, lowercase, no period
- Format: "add login page" not "Added login page functionality"

## Environment
(leave as placeholder — user fills in tmux layout, auto-reload behavior etc.)
```

4. After writing, read the file back, flag anything that looks wrong or hallucinated, and show the user the full file.
5. Create a pointer so Claude Code loads AGENTS.md:

```bash
echo "@AGENTS.md" > CLAUDE.md
```
