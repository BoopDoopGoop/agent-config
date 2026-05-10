---
name: ship
description: Simplify, review, verify, commit, and push intended changes
---

Use this when the user asks to ship, commit, or push current work.

Steps:
- Simplify recent changes where a cleaner local shape is obvious.
- Review `git diff HEAD`.
- Fix real bugs, style issues, and convention mismatches.
- Re-run the relevant verification.
- Stage intended changes only.
- Commit with a single-line lowercase imperative message, no period.
- Push.
- Run `git fetch` as a separate command after pushing so local remote-tracking refs reflect the pushed commit.
