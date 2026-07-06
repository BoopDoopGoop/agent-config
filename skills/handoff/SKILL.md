---
name: handoff
description: Save an explicitly approved implementation plan to plans/
---

Use this only when the user asks to save or hand off an approved plan for later implementation. Do not use for ordinary in-chat planning.

Steps:
- Check `plans/` for a related existing plan first; update it instead of duplicating it.
- Save the approved plan as `plans/NN-slug.md` using the next unused two-digit number.
- Use this format:
  - `## Goal`: one short paragraph.
  - `## Tasks`: one unified top checklist.
  - Task IDs: `T1`, `T2`, etc.; note dependencies inline.
  - One section per task with `Files`, `Changes`, `Connections`, `Depends`, and `Verify`.
  - Add `## Final Check` only for multi-task, cross-cutting, UI, integration, or refactor work.
- Do not commit, push, sync, branch, pull, mark status, or archive.
