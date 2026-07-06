---
name: bootstrap
description: Inspect a repo and create or update minimal AGENTS.md / CLAUDE.md project instructions
---

Use this when the user asks to bootstrap or refresh per-repo agent instructions.

Steps:
- Inspect existing `AGENTS.md`, `CLAUDE.md`, README/docs, package manager files, scripts, test/lint/typecheck configs, build system, and top-level layout.
- Use documented commands first; ask when setup or verification remains unclear after inspection.
- Write the shortest useful project instruction file(s): purpose, repo map, setup, focused/full test, lint, typecheck/build, dependency policy, conventions, definition of done, and protected paths.
- Include focused verification commands where possible.
- Keep content repo-specific and command-focused; rely on global rules for baseline behavior.
- Preserve useful repo-specific notes; prune stale or generic clutter.
- Verify by reviewing the diff and running the lowest-risk relevant check.
