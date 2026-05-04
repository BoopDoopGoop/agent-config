# Global Agent Rules

## Critical Rules
(leave empty — fill in reactively as agents make mistakes)

## Skills
- "ship" → ship skill
- "review" → review-plus-fix skill
- "take over" → take-over skill
- "spec" → spec skill
- "debug" → debug skill
- "reflect" → reflect-agents-md skill
- "bootstrap" → bootstrap-agents-md skill

## Plan Tracking

Plans live at `PLAN.md` in the project root.

Every plan file must include:

1. A `## Task Tracker` section with one checkbox per task:
   - [ ] Task 1: <one-line description>

2. A detail section for each task containing:
   - The exact files to create or modify (with line numbers where relevant)
   - The specific code to write — function signatures, class names, field names, exact values
   - How it connects to existing code (which functions to call, which patterns to follow)
   - A concrete **Verify:** step (a command to run or behavior to check)

Tasks must be sequential and self-contained.

After completing each task, run `/compact` before starting the next task.

## Python Projects

When working in Python projects that use `uv`, always use `uv run` directly — never prepend `PYTHONPATH=src`. If the project has a `pyproject.toml` with `[tool.setuptools.packages.find]`, install in editable mode via `uv pip install -e .`.
