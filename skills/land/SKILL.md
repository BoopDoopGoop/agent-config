---
name: land
description:
  Land a PR by monitoring conflicts, resolving them, waiting for repository
  checks, and merging with the repository's allowed policy; use when asked to
  land, merge, or shepherd a PR to completion.
---

# Land

## Goals

- Read the repository's `AGENTS.md` and follow its commands and conventions.
- Ensure the PR is conflict-free with its detected base branch.
- Keep the repository's native checks green and fix failures when they occur.
- Use the repository's documented or configured merge and branch-deletion
  policy.
- Do not yield to the user until the PR is merged; keep the watcher loop running
  unless blocked.

## Preconditions

- `gh` CLI is authenticated.
- You are on the PR branch with a clean working tree.

## Steps

1. Locate the PR for the current branch and read its base branch from PR
   metadata. Fall back to the remote's default branch only when no PR exists.
2. Read `AGENTS.md`, linked instructions, project docs, and configured
   workflows to identify native validation, review, merge, and branch policies.
3. Run the repository's required local checks before any push.
4. If the working tree has uncommitted changes, commit with the `commit` skill
   and push with the `push` skill before proceeding.
5. Check mergeability against the detected base branch.
6. If conflicts exist, use the `pull` skill to update from the configured
   remote and base branch, then use the `push` skill to publish the result.
7. Ensure all human and automated review comments are acknowledged and required
   fixes are handled before merging.
8. Watch the checks that the repository actually reports. If none are
   configured, confirm repository policy does not require them.
9. If checks fail, inspect logs, fix the issue, run native validation, commit
   with the `commit` skill, push with the `push` skill, and restart the watch.
10. When checks and review requirements are satisfied, merge using the strategy
    required by `AGENTS.md` or repository settings. Do not assume squash,
    rebase, merge-commit, auto-merge, or branch deletion.
11. **Context guard:** Before implementing review feedback, confirm it does not
    conflict with the user's stated intent or task context. If it conflicts,
    respond inline with a justification and ask the user before changing code.
12. **Pushback template:** When disagreeing, reply inline with: acknowledge +
    rationale + offer alternative.
13. **Ambiguity gate:** When ambiguity blocks progress, assign the PR to the
    current GitHub user, mention them, and wait for a response. Do not implement
    until ambiguity is resolved.
14. **Per-comment mode:** For each review comment, choose one of: accept,
    clarify, or push back. Reply in the same review context before changing code.
15. **Reply before change:** State the intended action before pushing changes.

## Commands

```sh
# Ensure branch and PR context
branch=$(git branch --show-current)
pr_number=$(gh pr view --json number -q .number)
pr_title=$(gh pr view --json title -q .title)
pr_body=$(gh pr view --json body -q .body)
base_branch=$(gh pr view --json baseRefName -q .baseRefName)

# Check mergeability and conflicts
mergeable=$(gh pr view --json mergeable -q .mergeable)
if [ "$mergeable" = "CONFLICTING" ]; then
  # Run the pull skill using the configured remote and "$base_branch".
  # Then run the push skill to publish the updated branch.
  exit 5
fi

# Preferred: use the Async Watch Helper below. The manual loop is a fallback.
if ! gh pr checks --watch; then
  gh pr checks
  # Inspect failures with gh run list/view or the repository's native CI tool.
  exit 1
fi

# Inspect allowed merge strategies and branch-deletion policy.
gh repo view --json mergeCommitAllowed,rebaseMergeAllowed,squashMergeAllowed,deleteBranchOnMerge

# Merge with the strategy required by repository policy. For example, use
# exactly one supported flag: --merge, --rebase, or --squash.
gh pr merge <allowed-strategy-flag> --subject "$pr_title" --body "$pr_body"
```

## Async Watch Helper

Use the globally installed watcher to monitor review comments, checks, and head
updates in parallel. Prefer the installation for the current agent, with a
fallback so the same skill works in Codex and Claude:

```sh
if [ -f "${CODEX_HOME:-$HOME/.codex}/skills/land/land_watch.py" ]; then
  land_watch="${CODEX_HOME:-$HOME/.codex}/skills/land/land_watch.py"
else
  land_watch="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/land/land_watch.py"
fi
python3 "$land_watch"
```

Exit codes:

- 2: Review comments detected (address feedback)
- 3: Reported checks failed
- 4: PR head updated
- 5: PR has merge conflicts

The helper exits successfully after reported checks pass. If the repository
reports no checks within the wait window, it exits successfully with a notice;
confirm that this matches repository policy before merging.

## Failure Handling

- If checks fail, inspect them with `gh pr checks` and `gh run view --log` or
  the repository's native CI tooling. Fix locally, run native validation,
  commit, push, and restart the watch.
- Use judgment to identify flaky failures. Rerun only when repository policy
  permits it and there is evidence the failure is unrelated to the change.
- If automation updates the PR head, sync the configured remote branch using the
  repository's documented workflow, validate, and push only if needed.
- If mergeability is `UNKNOWN`, wait and re-check.
- Do not merge while review comments or blocking review states are outstanding.
- Do not assume whether automated review jobs are blocking; follow repository
  settings and instructions.
- Do not enable auto-merge unless repository policy allows it and all required
  protections are configured.
- Never force-push unless the update workflow rewrote history; then use only
  `--force-with-lease`.

## Review Handling

- Treat automated review issue comments, including comments whose titles begin
  with `## Codex Review` or `## Claude Review`, as reviewer feedback.
- Human review comments are blocking unless repository policy explicitly says
  otherwise. Address and resolve them before requesting another review or
  merging.
- If multiple reviewers comment in one thread, respond to each comment before
  resolving it.
- Use review-comment endpoints for inline feedback and issue-comment endpoints
  for top-level discussion:

  ```sh
  gh api repos/{owner}/{repo}/pulls/<pr_number>/comments
  gh api repos/{owner}/{repo}/issues/<pr_number>/comments
  gh api -X POST /repos/{owner}/{repo}/pulls/<pr_number>/comments \
    -f body='[agent] <response>' -F in_reply_to=<comment_id>
  ```

- `in_reply_to` must be the numeric review comment id, and the endpoint must
  include the PR number.
- Use a repository-required comment prefix when one exists; otherwise use the
  neutral `[agent]` prefix. Do not attribute comments to a specific agent.
- For automated issue-comment reviews, reply in the issue thread and state
  whether the feedback will be addressed or deferred, including rationale.
- If feedback requires changes:
  - Reply with intended fixes in the original context.
  - Implement fixes, run native validation, commit, and push.
  - Reply with the fix details and commit SHA where the feedback was
    acknowledged.
- Request a new automated review only when repository policy supports it and
  there is a new commit since the previous request.
- Before requesting another review, run the watcher and ensure there is no
  outstanding feedback.
- After a batch of fixes, post one concise root-level update when useful:

  ```text
  [agent] Changes since last review:
  - <short bullets of deltas>
  Commits: <sha>, <sha>
  Tests: <commands run>
  ```

## Scope + PR Metadata

- Keep the PR title and description aligned with the full current scope.
- If feedback expands scope, decide whether to accept, defer, or decline it.
  Explain deferrals or declines with a brief reason.
- Validate correctness concerns before closing them.
- Classify each review comment as correctness, design, style, clarification, or
  scope.
- Prefer a consolidated root-level update after a batch of fixes.
- For documentation feedback, confirm the documentation matches behavior.
