---
name: implement
description: Execute an explicit saved plan from plans/
---

Use this only when the user asks to implement a saved plan file. Do not use for ordinary tasks or informal plans.

Steps:
- Use the named plan, or the highest-numbered plan in `plans/` if none is named.
- Read the whole plan before editing.
- Execute tasks in dependency order.
- For each task: make changes, run its `Verify`, then check it off in the unified top checklist.
- Run `Final Check` when present.
- Delete the plan file after all tasks pass verification.

Do not run git workflow steps or use active tracking.
