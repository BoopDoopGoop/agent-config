---
name: rename
description: Rename the main Codex task with a concise default-style title
---

Use this when the user asks to rename the main Codex task.

Steps:
- Derive a concise, sentence-case verb–object title from the main task's goal.
- Rename the main Codex task only; never rename a side conversation or subtask.
- Call `codex_app__set_thread_title` with the main task ID.
- Confirm the new title in one short sentence.
