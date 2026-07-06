---
name: bootstrap
description: Inspect a repo and create or update minimal AGENTS.md / CLAUDE.md project instructions
---

Use this when the user asks to bootstrap or refresh per-repo agent instructions.

Steps:
- Inspect existing `AGENTS.md`, `CLAUDE.md`, README/docs, package manager files, scripts, test/lint/typecheck configs, build system, and top-level layout.
- Prefer documented commands over guessing; ask only if setup or verification cannot be inferred.
- Write the shortest useful project instruction file(s): purpose, repo map, setup, focused/full test, lint, typecheck/build, dependency policy, conventions, definition of done, and avoid-touch paths.
- Include focused verification commands where possible.
- Avoid duplicating global rules or long behavioral philosophy.
- Preserve useful repo-specific notes; remove stale or generic clutter.
- Verify by reviewing the diff and running the lowest-risk relevant check.
