#!/usr/bin/env bash

set -euo pipefail

: "${HOME:?HOME must be set}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -n "${AGENT_CONFIG_DIR:-}" ]; then
  AGENT_CONFIG="$(cd "$AGENT_CONFIG_DIR" && pwd)"
else
  AGENT_CONFIG="$SCRIPT_DIR"
fi

CLAUDE_DIR="$HOME/.claude"
CODEX_DIR="$HOME/.codex"
CODEX_EXECPOLICY_DIR="$CODEX_DIR/execpolicy"

echo "Setting up agent config..."

CUSTOM_SKILLS=(bootstrap commit debug handoff implement land linear pull push retro ship sync)

require_path() {
  local path="$1"
  if [ ! -e "$AGENT_CONFIG/$path" ]; then
    echo "Missing required path: $AGENT_CONFIG/$path" >&2
    exit 1
  fi
}

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

require_path "AGENTS.md"
require_path "claude-code/settings.json"
require_path "claude-code/statusline-command.sh"
require_path "codex/config.toml"
require_path "codex/execpolicy/default.rules"
for skill in "${CUSTOM_SKILLS[@]}"; do
  require_path "skills/$skill/SKILL.md"
done

# ── Claude Code ──────────────────────────────────────────
# CLAUDE.md becomes a pointer to shared AGENTS.md
# Custom skills are linked individually; generated system skills stay agent-owned.
mkdir -p "$CLAUDE_DIR"
printf '%s\n' "@$AGENT_CONFIG/AGENTS.md" > "$CLAUDE_DIR/CLAUDE.md"
install_skill_links "$CLAUDE_DIR/skills"
ln -sf "$AGENT_CONFIG/claude-code/settings.json" "$CLAUDE_DIR/settings.json"
ln -sf "$AGENT_CONFIG/claude-code/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"
echo "✓ Claude Code"

# ── Codex ────────────────────────────────────────────────
# Codex reads ~/.codex/AGENTS.md as global config
mkdir -p "$CODEX_EXECPOLICY_DIR"
ln -sf "$AGENT_CONFIG/AGENTS.md" "$CODEX_DIR/AGENTS.md"
install_skill_links "$CODEX_DIR/skills"
if [ -L "$CODEX_DIR/config.toml" ]; then
  unlink "$CODEX_DIR/config.toml"
fi
cp "$AGENT_CONFIG/codex/config.toml" "$CODEX_DIR/config.toml"
ln -sf "$AGENT_CONFIG/codex/execpolicy/default.rules" "$CODEX_EXECPOLICY_DIR/default.rules"
echo "✓ Codex"

# ── Verification ─────────────────────────────────────────
test -f "$AGENT_CONFIG/AGENTS.md"
test "$(realpath "$CODEX_DIR/AGENTS.md")" = "$(realpath "$AGENT_CONFIG/AGENTS.md")"
grep -Fx "@$AGENT_CONFIG/AGENTS.md" "$CLAUDE_DIR/CLAUDE.md" >/dev/null
for skill in "${CUSTOM_SKILLS[@]}"; do
  test "$(realpath "$CODEX_DIR/skills/$skill")" = "$(realpath "$AGENT_CONFIG/skills/$skill")"
  test "$(realpath "$CLAUDE_DIR/skills/$skill")" = "$(realpath "$AGENT_CONFIG/skills/$skill")"
done
test "$(realpath "$CLAUDE_DIR/settings.json")" = "$(realpath "$AGENT_CONFIG/claude-code/settings.json")"
test "$(realpath "$CLAUDE_DIR/statusline-command.sh")" = "$(realpath "$AGENT_CONFIG/claude-code/statusline-command.sh")"
cmp -s "$CODEX_DIR/config.toml" "$AGENT_CONFIG/codex/config.toml"
test "$(realpath "$CODEX_EXECPOLICY_DIR/default.rules")" = "$(realpath "$AGENT_CONFIG/codex/execpolicy/default.rules")"

echo "Done."
