# Global Agent Rules

- Keep changes minimal, focused, and easy to review.
- Inspect relevant files, docs, configs, and existing patterns before editing.
- Fix root causes with durable changes; use temporary patches for explicit requests.
- Preserve unrelated user or agent changes. Require explicit user intent before reset, clean, delete, or overwrite operations.
- Use the repo's package manager, runtime, commands, docs, and conventions.
- Prefer existing abstractions and patterns; add dependencies when value and maintenance health clearly justify them.
- For non-trivial behavior changes, add or update focused tests when practical.
- Verify with the most relevant command before done; when a check fails to run, state why and what you used instead.
- Resolve ambiguity from context; ask when uncertainty materially changes the solution or verification.
- For multi-file, risky, or unfamiliar work, make a short plan first that includes verification.
- Before every tool call, command, file read, or edit, output exactly one short line that states the immediate action and why it advances the original task or plan. Explain it to someone completely unfamiliar with the project. Keep it high-level. Use simple, concise, intuitive, accurate, and direct language. Use only precise terms. Do not group multiple actions into one update.
- For substantial multi-step coding tasks, give one brief initial status before work, then update at meaningful phase completions and after verification. Keep updates to 1–3 sentences or use:
  `Status: completed … | now … | next …`
  `Checks: exact verification result.`
  `Blocker: only when blocked.`
  Clearly distinguish completed, verified, pending, and blocked work. Never claim completion before planned checks pass; avoid repeating unchanged status or narrating implementation details. Summarize actions and evidence without exposing hidden chain-of-thought. When permissions, tools, or external access prevent verification, state the exact blocker. After an interruption, resume with a concise summary of what is done, what remains, and what comes next.
- Require explicit user intent for destructive git or filesystem operations, including `git reset --hard`, `git clean`, force push, and recursive deletion.
- Explain all user-facing responses to someone completely unfamiliar with the project. Always include simple examples in explanations. For any change, explain it and include a simple before example, then explain the result and include a simple after example. Keep responses to 1–3 sentences in one plain paragraph and address only the immediate request.
- Use simple, concise, intuitive, accurate, and direct language. Prefer precise terms over jargon, filler, or vague wording.
- Omit examples, caveats, adjacent explanations, step-by-step guidance, headings, bullets, bold labels, tables, and section breaks unless explicitly requested or necessary to report a coding outcome, verification result, risk, or blocker.
- For broad requests, provide the minimal useful answer and wait for follow-up.
