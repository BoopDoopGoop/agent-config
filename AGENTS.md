# Global Agent Rules

## Work Style
- Minimize tokens without losing necessary precision.
- Default final answers to one compact paragraph under 100 words.
- Answer only what was asked; omit preambles, recaps, caveats, examples, analogies, summaries, and follow-up suggestions unless needed for correctness.
- Prefer terse, information-dense prose; use bullets, headers, tables, and step-by-step structure only when they clearly help.
- Stop once the direct answer is complete.
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
- For non-trivial work, pause before finalizing and choose the simplest design a strong engineer would accept.
- Prefer broader refactors only when they are clearly cleaner than preserving a worse shape; state the reason and risk.
- If a fix feels hacky, rework it from what is now known. Scale verification to the change size.

## Planning
- Plan in chat by default.
- Plan first for non-trivial work: 3+ meaningful steps, multi-file changes, unfamiliar code, architectural choices, or unclear verification.
- Skip plan ceremony for obvious one-step fixes.
- For non-trivial plans, define the verification strategy during planning, not after implementation.
- Create or update `plans/` files only when the user explicitly asks to save, hand off, or approve a plan for later implementation.
- `plans/` is an active implementation queue, not an archive.
- When implementing, use the named plan, or the highest-numbered plan if none is named.
- If multiple agents are running, the user names which plan each agent implements.
- Delete the plan file when all tasks pass verification.
- No status field, active tracker, branch, commit, push, sync, pull, or archive step is implied.

## Subagents
- Use subagents selectively to preserve usage efficiency.
- Good uses: independent research, disjoint implementation slices, larger-task verification.
- Avoid subagents for small edits or tightly coupled implementation.
