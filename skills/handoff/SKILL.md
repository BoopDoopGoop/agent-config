---
name: handoff
description: Save an explicitly approved implementation plan to plans/
---

Use this for explicit saved-plan handoff requests. For ordinary in-chat planning, make the plan in chat.

Steps:
- Check `plans/` for a related existing plan first; update it instead of duplicating it.
- Save the approved plan as `plans/NN-slug.md` using the next unused two-digit number.
- Use this format:
  - `## Goal`: one short paragraph.
  - `## Tasks`: one unified top checklist.
  - Task IDs: `T1`, `T2`, etc.; note dependencies inline.
  - One section per task with `Files`, `Changes`, `Connections`, `Depends`, and `Verify`.
  - Add `## Final Check` for multi-task, cross-cutting, UI, integration, or refactor work.
- Stop after saving the plan; leave commit, push, sync, branch, pull, status, and archive actions to explicit requests.
