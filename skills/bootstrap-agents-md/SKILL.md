---
name: bootstrap-agents-md
description: Read the project and generate a project-level AGENTS.md via Gemini CLI
---

DO NOT write AGENTS.md yourself. You must use the gemini CLI to generate it.

Run the following bash command from the project root. Collect the key files first, then embed their contents into the prompt:

```bash
gemini -p "$(cat <<'PROMPT'
Read this codebase and produce an AGENTS.md with the structure below.
Read actual files to determine commands and style patterns — do not guess.
Keep the whole file under 150 lines. Instructions only, no explanations.

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

---

Here are the project files:

FOLDER STRUCTURE:
$(ls -R . | head -80)

PACKAGE/PROJECT FILE:
$(cat pyproject.toml 2>/dev/null || cat package.json 2>/dev/null || echo "not found")

README:
$(cat README.md 2>/dev/null || echo "not found")

PROMPT
)" > AGENTS.md
```

After the command runs:
- Read the generated AGENTS.md
- Flag anything that looks wrong, hallucinated, or missing
- Show the user the full file before finishing

Then create two pointer files so all agents load AGENTS.md:

```bash
echo "@AGENTS.md" > CLAUDE.md
echo "@AGENTS.md" > GEMINI.md
```
