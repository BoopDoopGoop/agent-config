#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_CONFIG="${AGENT_CONFIG_DIR:-$SCRIPT_DIR}"

echo "Setting up agent config..."

CUSTOM_SKILLS=(bootstrap debug handoff implement retro ship)

install_skill_links() {
  local dest="$1"
  if [ -L "$dest" ]; then
    unlink "$dest"
  fi
  mkdir -p "$dest"
  if [ -L "$dest/skills" ]; then
    unlink "$dest/skills"
  fi
  for skill in "${CUSTOM_SKILLS[@]}"; do
    ln -sfn "$AGENT_CONFIG/skills/$skill" "$dest/$skill"
  done
}

# ── Claude Code ──────────────────────────────────────────
# CLAUDE.md becomes a pointer to shared AGENTS.md
# Custom skills are linked individually; generated system skills stay agent-owned.
mkdir -p "$HOME/.claude"
printf '%s\n' "@$AGENT_CONFIG/AGENTS.md" > "$HOME/.claude/CLAUDE.md"
install_skill_links "$HOME/.claude/skills"
ln -sf "$AGENT_CONFIG/claude-code/settings.json" "$HOME/.claude/settings.json"
ln -sf "$AGENT_CONFIG/claude-code/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
echo "✓ Claude Code"

# ── Codex ────────────────────────────────────────────────
# Codex reads ~/.codex/AGENTS.md as global config
mkdir -p "$HOME/.codex/execpolicy"
ln -sf "$AGENT_CONFIG/AGENTS.md" "$HOME/.codex/AGENTS.md"
install_skill_links "$HOME/.codex/skills"
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
for skill in "${CUSTOM_SKILLS[@]}"; do
  test "$(realpath "$HOME/.codex/skills/$skill")" = "$(realpath "$AGENT_CONFIG/skills/$skill")"
  test "$(realpath "$HOME/.claude/skills/$skill")" = "$(realpath "$AGENT_CONFIG/skills/$skill")"
done
test "$(realpath "$HOME/.claude/settings.json")" = "$(realpath "$AGENT_CONFIG/claude-code/settings.json")"
test "$(realpath "$HOME/.claude/statusline-command.sh")" = "$(realpath "$AGENT_CONFIG/claude-code/statusline-command.sh")"
cmp -s "$HOME/.codex/config.toml" "$AGENT_CONFIG/codex/config.toml"
test "$(realpath "$HOME/.codex/execpolicy/default.rules")" = "$(realpath "$AGENT_CONFIG/codex/execpolicy/default.rules")"

echo "Done."
