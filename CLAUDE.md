# devenv

Personal dev environment managed with symlinks via `install.sh`.

## Architecture

Two symlink patterns:
- **`.symlink` convention**: Files named `*.symlink` get linked to `~/.<name>` automatically.
- **Per-tool functions**: Tools with complex layouts have `install_*()` functions in `install.sh`.

Scripts in `bin/` use `#!/usr/bin/env bash` and are symlinked to `~/.local/bin/`.

Claude skill config lives in `claude/devenv.json` (symlinked to `~/.claude/devenv.json`). Skills read this at runtime for backup limits and work directory settings.

## Claude Skills

User-invocable skills live in `claude/skills/` (each symlinked to `~/.claude/skills/<name>/`):
- `/bootstrap` — scaffold a project from conventions, writes `.work/bootstrap.md` context marker in the project
- `/research` — scan conventions and codebase to produce structured context, saved to `.work/research/`
- `/plan` — create or refine a task list, saved to `.work/plans/`
- `/design` — create or refine a design doc from a plan, saved to `.work/designs/`; pass a free-form description to bootstrap a plan inline
- `/implement` — implement a task from a plan+design pair, saves notes to `.work/implementations/`

One internal skill (`user-invocable: false`) is called by other skills:
- `/resolve-conventions` — discover and read convention docs from configured layers

The full loop is: `/bootstrap` (new project) → `/research` → `/plan` → `/design` → `/implement` (repeat). `/bootstrap` is optional — `/plan` detects greenfield projects and can front-load scaffolding as task 1. `/research` can re-enter at any stage — run it before planning, after design, or when discoveries surface during implementation.

After bootstrap, `.work/bootstrap.md` in the project provides context to `/plan` and `/design` so they skip redundant infrastructure questions.

`/document` is a command in `claude/commands/` — sync all docs after changes.

`/plan` and `/design` both support refine mode: when invoked with no args and existing artifacts are found, they offer a picker. Refine mode backs up the current file to `.backup/` before writing.

## Convention Docs

Convention docs are markdown files that guide skills at runtime. They live in `claude/conventions/` (symlinked to `~/.claude/conventions/`). Drop `.md` files into this directory and skills discover them automatically via YAML frontmatter.

The `conventions.md` file in that directory documents the format — frontmatter schema, available sections, and how to get started. It is not a convention itself.

Convention discovery is handled by the `/resolve-conventions` skill (`user-invocable: false`) — called by other skills. It reads `~/.claude/conventions/` directly. When `~/.config/devenv/convention-layers` exists (created by the optional [devenv-conventions](https://github.com/minusblindfold/devenv-conventions) expansion), it switches to layered mode with multiple convention sources and precedence ordering.

### Convention Frontmatter Schema

```yaml
---
keywords: [entity, model, JPA, persistence]   # Required. Terms for keyword-based discovery.
scope: all                                      # Optional: bootstrap | feature | all (default)
extends: false                                  # Optional: append to higher-precedence version (default: false)
---
```

### Convention Packs

For organized, reusable convention sets with management tooling (enable/disable packs, layered resolution, multiple active packs), see [devenv-conventions](https://github.com/minusblindfold/devenv-conventions).

## Documentation

After any config, tool, or script change, run `/document` to sync all docs.
