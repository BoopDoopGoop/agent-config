# Global Agent Rules

- Keep changes minimal, focused, and easy to review.
- Inspect relevant files, docs, configs, and existing patterns before editing.
- Fix root causes; avoid temporary patches unless explicitly requested.
- Preserve unrelated user or agent changes. Do not reset, clean, delete, or overwrite work you did not create without explicit instruction.
- Use the repo's package manager, runtime, commands, docs, and conventions.
- Prefer existing abstractions and patterns; add dependencies only when clearly justified by value and maintenance health.
- For non-trivial behavior changes, add or update focused tests when practical.
- Verify with the most relevant command before done; if verification is skipped, state why.
- Ask only when ambiguity materially changes the solution or verification and cannot be inferred.
- For multi-file, risky, or unfamiliar work, make a short plan first that includes verification.
- Require explicit user intent for destructive git or filesystem operations, including `git reset --hard`, `git clean`, force push, and recursive deletion.
