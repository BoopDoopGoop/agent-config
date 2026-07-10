---
name: commit
description:
  Create a well-formed git commit from current changes using session history for
  rationale and summary; use when asked to commit, prepare a commit message, or
  finalize staged work.
---

# Commit

## Goals

- Produce a commit that reflects the actual code changes and the session
  context.
- Follow the repository's commit conventions, with a concise fallback when none
  are documented.
- Include summary and rationale when a body is warranted.

## Inputs

- Current agent session history for intent and rationale.
- `git status`, `git diff`, and `git diff --staged` for actual changes.
- The repository's `AGENTS.md` and any linked instructions for commands and
  commit conventions.

## Steps

1. Read the repository's `AGENTS.md` and follow its commands and conventions.
2. Read session history to identify scope, intent, and rationale.
3. Inspect the working tree and staged changes (`git status`, `git diff`,
   `git diff --staged`).
4. Stage intended changes, including new files (`git add -A`) after confirming
   scope.
5. Sanity-check newly added files; if anything looks random or likely ignored
   (build artifacts, logs, temp files), flag it to the user before committing.
6. If staging is incomplete or includes unrelated files, fix the index or ask
   for confirmation.
7. Follow the repository's commit-message format. If none is documented, use
   an imperative subject no longer than 72 characters with no trailing period;
   use a conventional type and optional scope only when it matches local
   history.
8. Write a body when the repository convention or change complexity warrants
   one. Include:
   - Summary of key changes (what changed).
   - Rationale and trade-offs (why it changed).
   - Tests or validation run (or explicit note if not run).
9. Add attribution trailers only when the user or repository explicitly
   requires them; do not assume an agent identity.
10. Wrap body lines according to repository convention, defaulting to 72
    characters.
11. Create the commit message with a here-doc or temp file and use
    `git commit -F <file>` so newlines are literal (avoid `-m` with `\n`).
12. Commit only when the message matches the staged changes: if the staged diff
    includes unrelated files or the message describes work that isn't staged,
    fix the index or revise the message before committing.

## Output

- A single commit created with `git commit` whose message reflects the session.

## Template

Use this fallback only when the repository has no documented format. Type and
scope are optional examples.

```
<type>(<scope>): <short summary>

Summary:
- <what changed>
- <what changed>

Rationale:
- <why>
- <why>

Tests:
- <command or "not run (reason)">
```
