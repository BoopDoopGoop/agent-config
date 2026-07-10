# agent-config

Global coding-agent configuration for Codex and Claude Code.

This repo owns user-level behavior: global instructions, shared skills, Claude Code settings, Codex settings, and Codex execpolicy guardrails. Project-specific instructions belong in each project repo, typically in that repo's `AGENTS.md`, `CLAUDE.md`, README, or setup docs.

## Install

Run from a cloned copy of this repo:

```sh
./setup.sh
```

`setup.sh` installs config under `$HOME`:

- Codex: `~/.codex/AGENTS.md`, `~/.codex/skills/`, `~/.codex/config.toml`, `~/.codex/execpolicy/`
- Claude Code: `~/.claude/CLAUDE.md`, `~/.claude/skills/`, `~/.claude/settings.json`, `~/.claude/statusline-command.sh`

All install output stays under `$HOME`; project repos keep their own instructions.
Shared workflow skills include Linear GraphQL, commit, pull, push, and PR landing
support for repositories used from either Codex or Claude Code.

## Cloud Usage

In cloud or disposable environments, the project repo should clone normally, then its setup script should fetch this repo into `$HOME` and run this repo's `setup.sh`. Keep global config here and project facts in the project repo.

Pin this repo from project setup using a tag or commit ref. Recommended release tag format:

```text
v0.1.0
```

## Project Repo Integration

Example `.agent-config.lock`:

```sh
AGENT_CONFIG_REPO="https://github.com/BoopDoopGoop/agent-config.git"
AGENT_CONFIG_REF="v0.1.0"
```

Example `scripts/setup-cloud.sh`:

```sh
#!/usr/bin/env bash
set -euo pipefail

if [ -f ".agent-config.lock" ]; then
  . ".agent-config.lock"
fi

AGENT_CONFIG_REPO="${AGENT_CONFIG_REPO:-https://github.com/BoopDoopGoop/agent-config.git}"
AGENT_CONFIG_REF="${AGENT_CONFIG_REF:-v0.1.0}"
AGENT_CONFIG_DIR="$HOME/.agent-config"

if [ ! -d "$AGENT_CONFIG_DIR/.git" ]; then
  git clone "$AGENT_CONFIG_REPO" "$AGENT_CONFIG_DIR"
fi

git -C "$AGENT_CONFIG_DIR" fetch --tags --depth 1 origin "$AGENT_CONFIG_REF"
git -C "$AGENT_CONFIG_DIR" checkout --detach FETCH_HEAD
"$AGENT_CONFIG_DIR/setup.sh"
```

Create the tag in this repo separately when you are ready to publish a pinned config version.
