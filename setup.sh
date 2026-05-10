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
ln -sf "$AGENT_CONFIG/claude-code/settings.json" "$HOME/.claude/settings.json"
ln -sf "$AGENT_CONFIG/claude-code/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
echo "✓ Claude Code"

# ── Codex ────────────────────────────────────────────────
# Codex reads ~/.codex/AGENTS.md as global config
mkdir -p "$HOME/.codex/execpolicy"
ln -sf "$AGENT_CONFIG/AGENTS.md" "$HOME/.codex/AGENTS.md"
ln -sfn "$AGENT_CONFIG/skills" "$HOME/.codex/skills"
if [ -L "$HOME/.codex/config.toml" ]; then
  unlink "$HOME/.codex/config.toml"
fi
cp "$AGENT_CONFIG/codex/config.toml" "$HOME/.codex/config.toml"
ln -sf "$AGENT_CONFIG/codex/execpolicy/default.rules" "$HOME/.codex/execpolicy/default.rules"
echo "✓ Codex"

# ── Verification ─────────────────────────────────────────
test -f "$AGENT_CONFIG/AGENTS.md"
test "$(realpath "$HOME/.codex/AGENTS.md")" = "$(realpath "$AGENT_CONFIG/AGENTS.md")"
grep -Fx "@$AGENT_CONFIG/AGENTS.md" "$HOME/.claude/CLAUDE.md" >/dev/null
test "$(realpath "$HOME/.codex/skills")" = "$(realpath "$AGENT_CONFIG/skills")"
test "$(realpath "$HOME/.claude/skills")" = "$(realpath "$AGENT_CONFIG/skills")"
test "$(realpath "$HOME/.claude/settings.json")" = "$(realpath "$AGENT_CONFIG/claude-code/settings.json")"
test "$(realpath "$HOME/.claude/statusline-command.sh")" = "$(realpath "$AGENT_CONFIG/claude-code/statusline-command.sh")"
cmp -s "$HOME/.codex/config.toml" "$AGENT_CONFIG/codex/config.toml"
test "$(realpath "$HOME/.codex/execpolicy/default.rules")" = "$(realpath "$AGENT_CONFIG/codex/execpolicy/default.rules")"

echo ""
echo "Done. All agents now share $AGENT_CONFIG/AGENTS.md and $AGENT_CONFIG/skills/"
echo ""
echo "Next steps:"
echo "  1. Review $AGENT_CONFIG/AGENTS.md and fill in your personal conventions"
echo "  2. Open a new project and run the 'bootstrap' skill to generate a project-level AGENTS.md"
