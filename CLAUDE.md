# devenv

Personal dev environment managed with symlinks via `install.sh`.

## Architecture

Two symlink patterns:
- **`.symlink` convention**: Files named `*.symlink` get linked to `~/.<name>` automatically.
- **Per-tool functions**: Tools with complex layouts have `install_*()` functions in `install.sh`.

Scripts in `bin/` use `#!/usr/bin/env bash` and are symlinked to `~/.local/bin/`.

Claude skill config lives in `claude/devenv.json` (symlinked to `~/.claude/devenv.json`). Skills read this at runtime for settings like backup limits and work directory.

## Claude Skills

Three skills live in `claude/skills/` (each symlinked to `~/.claude/skills/<name>/`):
- `/plan` — create or refine a task list, saved to `.work/plans/`
- `/design` — create or refine a design doc from a plan, saved to `.work/designs/`; pass a free-form description to bootstrap a plan inline
- `/implement` — implement a task from a plan+design pair, saves notes to `.work/implementations/`

`/document` is a command in `claude/commands/` — sync all docs after changes.

`/plan` and `/design` both support refine mode: when invoked with no args and existing artifacts are found, they offer a picker. Refine mode backs up the current file to `.backup/` before writing.

## Documentation

After any config, tool, or script change, run `/document` to sync all docs.
