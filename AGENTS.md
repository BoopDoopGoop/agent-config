# Global Agent Rules

## Critical Rules
(leave empty — fill in reactively as agents make mistakes)

## Skills
- "ship" → ship skill
- "sync plan" → sync-plan skill
- "implement" → implement-plan skill
- "review" → review-plus-fix skill
- "take over" → take-over skill
- "spec" → spec skill
- "debug" → debug skill
- "reflect" → reflect-agents-md skill
- "bootstrap" → bootstrap-agents-md skill

## Plan Tracking

Plans live in `plans/`.

Use one file per independent effort: `plans/XX-short-task-name.md`.
Use the next two-digit number from existing plans, e.g. `01-add-auth.md`, then `02-refactor-billing.md`.

Before creating a plan, check `plans/` for an existing related plan and update it instead of duplicating it.

Claude Code Plan Mode UI/sidebar plans are drafts. When the user approves or asks to save one, write it to `plans/XX-short-task-name.md`, commit only that plan file with `sync plans`, and push. Do not implement unless explicitly asked.

Every plan file must include:
1. `## Status`
   - `unclaimed` or `claimed`
2. `## Task Tracker`
   - [ ] Task 1: <one-line description>
3. A detail section for each task:
   - Files to create or modify
   - Specific code changes
   - Existing code connections
   - A concrete **Verify:** step (a command to run or behavior to check)

Tasks must be sequential and self-contained. Parallel plans must not touch the same files or APIs unless their dependency is documented.

Before implementing, run `git pull --ff-only`, select the specified plan or highest-numbered `unclaimed` plan, mark it `claimed`, commit only that plan file with `sync plans`, and push.

Implement on branch `plan/XX-short-task-name` matching the plan filename without `.md`. Do not use worktrees unless explicitly asked.

After each task, update the checkbox, run its Verify step, then run `/compact`.

When all tasks are complete, delete the plan file, commit only that deletion with `sync plans`, and push.

## Python Projects

These are global defaults. Project-level AGENTS.md instructions override this section.

When working in Python projects that use `uv`, always use `uv run` directly — never prepend `PYTHONPATH=src`. If the project has a `pyproject.toml` with `[tool.setuptools.packages.find]`, install in editable mode via `uv pip install -e .`.
