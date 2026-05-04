#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_CONFIG="${AGENT_CONFIG_DIR:-$SCRIPT_DIR}"

echo "Setting up agent config symlinks..."

# ── Claude Code ──────────────────────────────────────────
# CLAUDE.md becomes a pointer to shared AGENTS.md
# Skills directory is symlinked from shared location
mkdir -p "$HOME/.claude"
printf '%s\n' "@$AGENT_CONFIG/AGENTS.md" > "$HOME/.claude/CLAUDE.md"
ln -sfn "$AGENT_CONFIG/skills" "$HOME/.claude/skills"
echo "✓ Claude Code"

# ── Codex ────────────────────────────────────────────────
# Codex reads ~/.codex/AGENTS.md as global config
mkdir -p "$HOME/.codex"
ln -sf "$AGENT_CONFIG/AGENTS.md" "$HOME/.codex/AGENTS.md"
ln -sfn "$AGENT_CONFIG/skills" "$HOME/.codex/skills"
echo "✓ Codex"

# ── Gemini CLI ───────────────────────────────────────────
# Gemini reads ~/.gemini/GEMINI.md; supports @file imports
mkdir -p "$HOME/.gemini"
printf '%s\n' "@$AGENT_CONFIG/AGENTS.md" > "$HOME/.gemini/GEMINI.md"
echo "✓ Gemini CLI"

# ── Verification ─────────────────────────────────────────
test -f "$AGENT_CONFIG/AGENTS.md"
test "$(realpath "$HOME/.codex/AGENTS.md")" = "$(realpath "$AGENT_CONFIG/AGENTS.md")"
grep -Fx "@$AGENT_CONFIG/AGENTS.md" "$HOME/.claude/CLAUDE.md" >/dev/null
test "$(realpath "$HOME/.codex/skills")" = "$(realpath "$AGENT_CONFIG/skills")"
test "$(realpath "$HOME/.claude/skills")" = "$(realpath "$AGENT_CONFIG/skills")"

echo ""
echo "Done. All agents now share $AGENT_CONFIG/AGENTS.md and $AGENT_CONFIG/skills/"
echo ""
echo "Next steps:"
echo "  1. Review $AGENT_CONFIG/AGENTS.md and fill in your personal conventions"
echo "  2. Install Gemini CLI if not already: npm install -g @google/gemini-cli && gemini auth"
echo "  3. Open a new project and run the 'bootstrap' skill to generate a project-level AGENTS.md"
