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

Plans live in the `plans/` directory in the project root.

Use one plan file per independent effort. Multiple plan files may exist at the same time for parallel work.

Plan filenames must be descriptive and stable:
`plans/XX-short-task-name.md`

Use the next sequential two-digit number based on existing plan files in `plans/`. For example, if `plans/` already contains `01-add-auth.md` and `02-refactor-billing.md`, create the next plan as `03-short-task-name.md`.

Before creating a new plan, check `plans/` for an existing related plan. If one exists, update it instead of creating a duplicate.

Every plan file must include:

1. A `## Status` section:
   - `unclaimed` or `claimed`

2. A `## Task Tracker` section with one checkbox per task:
   - [ ] Task 1: <one-line description>

3. A detail section for each task containing:
   - The exact files to create or modify (with line numbers where relevant)
   - The specific code to write — function signatures, class names, field names, exact values
   - How it connects to existing code (which functions to call, which patterns to follow)
   - A concrete **Verify:** step (a command to run or behavior to check)

Tasks must be sequential and self-contained.

Different plan files may be implemented in parallel only if their file ownership does not overlap. If two plans touch the same files or APIs, merge them or explicitly document the dependency.

Before implementing a plan, run `git pull --ff-only`, inspect `plans/`, and select the highest-numbered unclaimed plan unless the user specifies a plan number. Mark the selected plan as `claimed`, stage only that plan file, commit the claim with the exact message `sync plans`, and push it before changing implementation files.

Implement each plan on a branch named `plan/XX-short-task-name`, matching the plan filename without `.md`. Do not use git worktrees unless the user explicitly asks for them.

After completing each task, run `/compact` before starting the next task.

When all tasks in a plan are complete:
1. Delete the plan file.
2. Stage the deleted plan file.
3. Commit with the exact message `sync plans`.
4. Push the commit.

## Python Projects

These are global defaults. Project-level AGENTS.md instructions override this section.

When working in Python projects that use `uv`, always use `uv run` directly — never prepend `PYTHONPATH=src`. If the project has a `pyproject.toml` with `[tool.setuptools.packages.find]`, install in editable mode via `uv pip install -e .`.
