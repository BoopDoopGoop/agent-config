---
name: debug
description: Run a concise reproduce-hypothesize-fix-verify loop until working
---

Use this when the user reports broken behavior or an error.

Loop until working or genuinely blocked:
- Reproduce the failure, or read the most relevant logs/output when reproduction is not available.
- State the current hypothesis before editing.
- Fix the root cause, keeping the change focused.
- Verify the failure is gone with the relevant command or behavior check.
- If verification fails, update the hypothesis and repeat.

Report the cause, fix, and verification when done.
