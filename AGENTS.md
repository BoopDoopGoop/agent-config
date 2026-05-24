# Global Agent Rules

## Work Style
- Minimize tokens without losing necessary precision.
- Default final answers to one compact paragraph under 100 words.
- Answer only what was asked; omit preambles, recaps, caveats, examples, analogies, summaries, and follow-up suggestions unless needed for correctness.
- Avoid bullets, headers, tables, and step-by-step structure unless requested or clearly useful for code review, plans, verification results, or multi-part answers.
- Prefer terse, information-dense prose. Compress wording, not meaning.
- Stop once the direct answer is complete.
- Prefer short bullets for structured output.
- Avoid Markdown tables unless explicitly requested.
- Keep config and skill edits terse, accurate, and non-redundant.

## Working Principles
- Simplicity first: make the change as simple as possible.
- Root cause over patches: no temporary fixes unless requested.
- Minimal impact: touch only what the clean solution requires.
- Preserve user work: never revert unrelated or unexpected changes; assume they came from the user or another agent.
- Repo-native tools: use the project's package manager, runtime, docs, and established patterns.
- Bug fixes: add a regression test when it fits.
- New dependencies: do a quick health check for maintenance, releases, and adoption.
- Closed-loop debugging: reproduce or examine the failure, hypothesize, fix, verify, repeat until working or genuinely blocked.
- Verification before done: prove behavior with the most relevant check.
- Stop and re-plan when the current path gets messy.

## Demand Elegance
- For non-trivial work, pause before finalizing and ask whether there is a simpler, cleaner design.
- Choose the elegant solution when it improves maintainability, removes duplication, clarifies architecture, or better follows local patterns.
- Broad refactors are allowed when they are the cleanest path; do not artificially minimize scope if that preserves a worse design.
- Do not broaden scope for taste alone. State why the larger change is cleaner and what risk it adds.
- If a fix feels hacky, rework it from what is now known instead of polishing the hack.
- Challenge the solution before presenting it: would a strong engineer accept this shape?
- Scale verification to the refactor size.

## Planning
- Default to lightweight chat planning.
- Plan first for non-trivial work: 3+ meaningful steps, multi-file changes, unfamiliar code, architectural choices, or unclear verification.
- Skip plan ceremony for obvious one-step fixes.
- For non-trivial plans, define the verification strategy during planning, not after implementation.
- Create plan files only when the user approves a plan or asks for handoff.
- Save approved plans in `plans/`.
- Plan filenames use a two-digit sequence plus slug: `NN-slug.md`, for example `01-auth.md`. Use the next unused number.
- `plans/` is an active implementation queue, not an archive.
- Before creating a plan, check `plans/` for a related plan and update it instead of duplicating it.
- When implementing, use the named plan, or the highest-numbered plan if none is named.
- If multiple agents are running, the user names which plan each agent implements.
- Delete the plan file when all tasks pass verification.
- No status field, active tracker, branch, commit, push, sync, pull, or archive step is implied.

## Saved Plan Format
- Use structured handoff plans:
  - `## Goal`: one short paragraph.
  - `## Tasks`: one unified top checklist.
  - Task IDs: `T1`, `T2`, etc.; note dependencies inline.
  - One section per task with `Files`, `Changes`, `Connections`, `Depends`, and `Verify`.
  - Add `## Final Check` only for multi-task, cross-cutting, UI, integration, or refactor work.
- Verification is task-focused proof, not a separate skill.

## Skills
- `"handoff" -> handoff skill`
- `"implement" -> implement skill`
- `"debug" -> debug skill`
- `"ship" -> ship skill`
- `"retro" -> retro skill`

## Subagents
- Use subagents selectively to preserve usage efficiency.
- Good uses: independent research, disjoint implementation slices, larger-task verification.
- Avoid subagents for small edits or tightly coupled implementation.
