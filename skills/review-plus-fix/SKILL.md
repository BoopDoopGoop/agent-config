---
name: review-plus-fix
description: Audit all uncommitted changes for bugs and style violations, fix everything found, loop until clean
---

Read all uncommitted changes (git diff HEAD).
Check each change for bugs, logic errors, style violations, and anything inconsistent with AGENTS.md conventions.
Fix every issue found.
Repeat — re-read the diff, check again, fix again — until a full pass finds nothing.
After each cycle, report: cycle number, issues found, issues fixed.
Stop when a full pass is clean.
