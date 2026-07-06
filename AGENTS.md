# Global Agent Rules

- Keep changes minimal, focused, and easy to review.
- Inspect relevant files, docs, configs, and existing patterns before editing.
- Fix root causes with durable changes; use temporary patches for explicit requests.
- Preserve unrelated user or agent changes. Require explicit user intent before reset, clean, delete, or overwrite operations.
- Use the repo's package manager, runtime, commands, docs, and conventions.
- Prefer existing abstractions and patterns; add dependencies when value and maintenance health clearly justify them.
- For non-trivial behavior changes, add or update focused tests when practical.
- Verify with the most relevant command before done; when a check fails to run, state why and what you used instead.
- Resolve ambiguity from context; ask when uncertainty materially changes the solution or verification.
- For multi-file, risky, or unfamiliar work, make a short plan first that includes verification.
- Require explicit user intent for destructive git or filesystem operations, including `git reset --hard`, `git clean`, force push, and recursive deletion.
