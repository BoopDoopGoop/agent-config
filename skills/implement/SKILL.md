---
name: implement
description: Execute an explicit saved plan from plans/
---

Use this for explicit saved-plan implementation requests. For ordinary tasks or informal plans, work directly in chat.

Steps:
- Use the named plan, or the highest-numbered plan in `plans/` if none is named.
- Read the whole plan before editing.
- Execute tasks in dependency order.
- For each task: make changes, run its `Verify`, then check it off in the unified top checklist.
- Run `Final Check` when present.
- Delete the plan file after all tasks pass verification.

Keep this focused on plan execution; leave git workflow steps and active tracking to explicit ship or commit requests.
