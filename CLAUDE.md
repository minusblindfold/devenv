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
- `/research` — scan rules and codebase to produce structured context, saved to `.work/research/`
- `/plan` — create or refine a task list, saved to `.work/plans/`
- `/design` — create or refine a design doc from a plan, saved to `.work/designs/`; pass a free-form description to bootstrap a plan inline
- `/implement` — implement a task from a plan+design pair, saves notes to `.work/implementations/`
- `/bootstrap` — scaffold a project from rules, writes `.work/bootstrap.md` context marker in the project

One internal skill (`user-invocable: false`) is called by other skills:
- `/resolve-rules` — discover and read rule docs from configured layers

The full loop is: `/bootstrap` (new project) → `/research` → `/plan` → `/design` → `/implement` (repeat). `/bootstrap` is optional — `/plan` detects greenfield projects and can front-load scaffolding as task 1. `/research` can re-enter at any stage — run it before planning, after design, or when discoveries surface during implementation.

After bootstrap, `.work/bootstrap.md` in the project provides context to `/plan` and `/design` so they skip redundant infrastructure questions.

`/document` is a command in `claude/commands/` — sync all docs after changes.

`/plan` and `/design` both support refine mode: when invoked with no args and existing artifacts are found, they offer a picker. Refine mode backs up the current file to `.backup/` before writing.

## Rules

Rules are markdown files that guide skills at runtime. They live in `claude/rules/` (symlinked to `~/.claude/rules/`). Drop `.md` files here and they work everywhere — Claude Code reads them automatically, and skills use frontmatter keywords to find the right ones for each task.

The `rules.md` file in that directory documents the format and how to get started. It is not a rule itself.

### Rule Frontmatter

Only `keywords` is required for project-level rules:

```yaml
---
keywords: [entity, model, JPA, persistence]
---
```

`scope` and `extends` are additional fields used by rule packs for layered resolution. See `rules.md` for the full schema.

### Rule Discovery

Handled by the `/resolve-rules` skill (`user-invocable: false`) — called by other skills. It reads `~/.claude/rules/` directly. When `~/.config/devenv/rule-layers` exists (created by the optional [devenv-rules](https://github.com/minusblindfold/devenv-rules) expansion), it switches to layered mode with multiple rule sources and precedence ordering.

## Documentation

After any config, tool, or script change, run `/document` to sync all docs.
