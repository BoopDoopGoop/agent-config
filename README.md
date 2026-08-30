# OpenCode Configuration

Global OpenCode configuration and the BTW plugin package.

## Install

Run from a cloned copy of this repo:

```sh
./setup.sh
```

`setup.sh` symlinks the OpenCode configuration into `~/.config/opencode/`.
It includes only `opencode.jsonc`, Oh My OpenCode Slim settings, and TUI
settings. OpenCode downloads third-party plugins listed in `opencode.jsonc`
automatically at startup, including `@boopdoopgoop/opencode-btw`.

## BTW Package Development

The public plugin lives in `packages/opencode-btw`:

```sh
cd packages/opencode-btw
bun install
bun run check
```

To release a new package version, update its `package.json`, run the checks,
and publish from that package directory:

```sh
bun run check
npm publish --access public
```
