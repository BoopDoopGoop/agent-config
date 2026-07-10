---
name: sync
description: Safely sync local or cloud git work with the remote branch. Use when the user asks to sync with remote, pull latest, update from remote, reconcile local and cloud work, resolve merge conflicts, continue after cloud work landed, or prepare a branch after local/cloud handoff.
---

Use this to make local and remote branch state explicit before moving work across the git boundary.

Steps:
- Inspect current state first: `git status --short --branch`, current branch, upstream, and any uncommitted changes.
- Fetch remote refs before deciding: `git fetch --prune` or the repo-native equivalent.
- Compare local `HEAD` with upstream using `git rev-list --left-right --count HEAD...@{upstream}` or an equivalent repo-native check.
- If the worktree is clean and local is behind upstream, pull or rebase using the repo convention.
- If the worktree is clean and local is ahead upstream, report that local commits need pushing.
- If local and upstream both have commits, choose the safest repo-native strategy: prefer rebase for local unpublished work; prefer merge when repo convention clearly uses merge commits.
- If uncommitted changes exist, inspect them and ask before stashing unless the repo has an obvious established safe workflow.
- If conflicts occur, inspect conflicting files, resolve straightforward conflicts while preserving both local and remote intent, then run the narrowest relevant verification.
- Stop when conflict intent is ambiguous and report the exact files, conflict sections, and decision needed.
- After syncing, run verification scaled to the change.

Safety:
- Never run `git reset --hard`.
- Never run `git clean`.
- Never force push.
- Never delete branches.
- Never discard uncommitted work.
- Never rewrite published or shared history without explicit instruction.
- Prefer explicit status reporting over clever automation.

Report:
- Starting branch and status.
- Action taken.
- Conflicts resolved or reason blocked.
- Verification run.
- Final branch status.
