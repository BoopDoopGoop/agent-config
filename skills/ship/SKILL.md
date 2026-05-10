---
name: ship
description: Simplify, review, verify, commit, and push intended changes
---

Use this when the user asks to ship, commit, or push current work.

Steps:
- Simplify recent changes where a cleaner local shape is obvious.
- Review `git diff HEAD`.
- Fix real bugs, style issues, and convention mismatches.
- Run only verification relevant to the change; for tiny text-only edits, diff review is enough.
- Stage intended changes only.
- Commit with a single-line lowercase imperative message, no period.
- Push.
- After push completes, silently run `git fetch` to refresh local tracking refs; do not mention it unless it fails.
