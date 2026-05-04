---
name: implement-plan
description: Pull latest plans, claim the latest unclaimed plan, then implement it task by task
---

Use this when asked to implement a plan, take the next plan, or work from `plans/`.

Pull latest changes with `git pull --ff-only`.
Inspect `plans/`.
If the user specifies a plan number, use that plan. Otherwise select the highest-numbered unclaimed plan matching `plans/XX-short-task-name.md`.
Do not implement a plan whose `## Status` section is `claimed` unless the user explicitly tells you to take it over.

Before changing implementation files:
1. Update the selected plan's `## Status` section to `claimed`.
2. Stage only that plan file.
3. Commit with the exact message `sync plans`.
4. Push.

Create and use an implementation branch named `plan/XX-short-task-name`, matching the plan filename without `.md`.
Do not use git worktrees unless the user explicitly asks for them.

Then implement the plan task by task.
After each task, update the task checkbox, run its Verify step, and run `/compact`.
When all tasks are complete, delete the plan file, commit the deletion with the exact message `sync plans`, and push.
