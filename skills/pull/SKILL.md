---
name: pull
description:
  Pull the latest configured upstream and base branch into the current local
  branch and resolve conflicts (aka update-branch). Use when an agent needs to
  sync a feature branch while following the repository's update policy.
---

# Pull

## Workflow

1. Read the repository's `AGENTS.md` and follow its commands, conventions, and
   branch-update policy.
2. Verify git status is clean or commit/stash changes before updating.
3. Ensure rerere is enabled locally:
   - `git config rerere.enabled true`
   - `git config rerere.autoupdate true`
4. Confirm remotes and branches:
   - Determine the current branch and its configured upstream remote. If no
     upstream exists, use the repository's sole remote or ask when ambiguous.
   - Ensure the current branch is the one to receive the update.
   - Detect the base branch from repository instructions, PR metadata, the
     remote's default branch, or `refs/remotes/<remote>/HEAD`, in that order.
5. Fetch latest refs from the detected remote.
6. Sync the remote feature branch first when it exists:
   - `git pull --ff-only <remote> $(git branch --show-current)`
   - This pulls branch updates made remotely (for example, a GitHub auto-commit)
     before integrating the base branch.
7. Integrate `<remote>/<base>` using the repository's documented merge or
   rebase workflow. If none is documented, infer the established strategy from
   recent branch history and hosted-repository settings; ask before rewriting a
   published branch when the safe choice remains ambiguous. Use
   `merge.conflictstyle=zdiff3` when merging for clearer conflict context.
8. If conflicts appear, resolve them (see conflict guidance below), then use
   the continuation command for the chosen update strategy:
   - `git add <files>`
   - `git merge --continue` or `git rebase --continue`
9. Verify with the repository's native checks from `AGENTS.md`, project docs,
   or configured workflows.
10. Summarize the update:
   - Call out the most challenging conflicts/files and how they were resolved.
   - Note any assumptions or follow-ups.

## Conflict Resolution Guidance (Best Practices)

- Inspect context before editing:
  - Use `git status` to list conflicted files.
  - Use `git diff` or `git diff --merge` to see conflict hunks.
  - Use `git diff :1:path/to/file :2:path/to/file` and
    `git diff :1:path/to/file :3:path/to/file` to compare base vs ours/theirs
    for a file-level view of intent.
  - With `merge.conflictstyle=zdiff3`, conflict markers include:
    - `<<<<<<<` ours, `|||||||` base, `=======` split, `>>>>>>>` theirs.
    - Matching lines near the start/end are trimmed out of the conflict region,
      so focus on the differing core.
  - Summarize the intent of both changes, decide the semantically correct
    outcome, then edit:
    - State what each side is trying to achieve (bug fix, refactor, rename,
      behavior change).
    - Identify the shared goal, if any, and whether one side supersedes the
      other.
    - Decide the final behavior first; only then craft the code to match that
      decision.
    - Prefer preserving invariants, API contracts, and user-visible behavior
      unless the conflict clearly indicates a deliberate change.
  - Open files and understand intent on both sides before choosing a resolution.
- Prefer minimal, intention-preserving edits:
  - Keep behavior consistent with the branch’s purpose.
  - Avoid accidental deletions or silent behavior changes.
- Resolve one file at a time and rerun tests after each logical batch.
- Use `ours/theirs` only when you are certain one side should win entirely.
- For complex conflicts, search for related files or definitions to align with
  the rest of the codebase.
- For generated files, resolve non-generated conflicts first, then regenerate:
  - Prefer resolving source files and handwritten logic before touching
    generated artifacts.
  - Run the CLI/tooling command that produced the generated file to recreate it
    cleanly, then stage the regenerated output.
- For import conflicts where intent is unclear, accept both sides first:
  - Keep all candidate imports temporarily, finish the merge, then run lint/type
    checks to remove unused or incorrect imports safely.
- After resolving, ensure no conflict markers remain:
  - `git diff --check`
- When unsure, note assumptions and ask for confirmation before finalizing the
  merge.

## When To Ask The User (Keep To A Minimum)

Do not ask for input unless there is no safe, reversible alternative. Prefer
making a best-effort decision, documenting the rationale, and proceeding.

Ask the user only when:

- The correct resolution depends on product intent or behavior not inferable
  from code, tests, or nearby documentation.
- The conflict crosses a user-visible contract, API surface, or migration where
  choosing incorrectly could break external consumers.
- A conflict requires selecting between two mutually exclusive designs with
  equivalent technical merit and no clear local signal.
- The merge introduces data loss, schema changes, or irreversible side effects
  without an obvious safe default.
- The branch is not the intended target, or the remote/branch names do not exist
  and cannot be determined locally.

Otherwise, proceed with the merge, explain the decision briefly in notes, and
leave a clear, reviewable commit history.
