# devenv

Personal dev environment managed with symlinks via `install.sh`.

## Architecture

Two symlink patterns:
- **`.symlink` convention**: Files named `*.symlink` get linked to `~/.<name>` automatically.
- **Per-tool functions**: Tools with complex layouts have `install_*()` functions in `install.sh`.

Scripts in `bin/` use `#!/usr/bin/env bash` and are symlinked to `~/.local/bin/`.

Claude skill config lives in `claude/devenv.json` (symlinked to `~/.claude/devenv.json`). Skills read this at runtime for settings like backup limits and work directory.

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

Shared reference docs live in `claude/conventions/` (symlinked to `~/.claude/conventions/`). Each describes a pattern that skills read at runtime:
- `stack.md` — project skeleton: language, framework, build system, infrastructure, startup commands
- `entity.md` — JPA entity annotations, Lombok, equals/hashCode, fetch strategy, @ManyToOne/@OneToMany
- `repository.md` — Spring Data JPA interfaces, derived query methods, return types
- `service.md` — interface + impl, transactions, validation, exceptions
- `controller.md` — role-based packages, auth guards, flash attributes, mutation safety
- `migration.md` — Liquibase YAML format, naming, master changelog, seed data with documented passwords
- `templates.md` — Thymeleaf fragments, directory layout, Bootstrap 5, single source of truth for navigation
- `security.md` — Role enum, UserDetailsService, SecurityConfig, AuthController, auth flow
- `docker-db.md` — Docker Compose, PostgreSQL, zero-friction dev startup via spring-boot-docker-compose

These are not invocable skills — they're knowledge files. Convention discovery is handled by the `/resolve-conventions` skill (`user-invocable: false`) — called by other skills to resolve conventions across configurable layers (set in `devenv.json` under `conventions.layers`).

### Convention Frontmatter Schema

Each convention doc has YAML frontmatter between `---` delimiters:

```yaml
---
keywords: [entity, model, JPA, persistence]   # Required. Terms for keyword-based discovery.
scope: all                                      # Optional. When this convention applies:
                                                #   bootstrap — only during project scaffolding
                                                #   feature   — only during feature implementation
                                                #   all       — both contexts (default if omitted)
extends: false                                  # Optional. If true, appends to a higher-precedence
                                                #   version instead of being overridden. Default: false.
---
```

Conventions with a `## Bootstrap` section describe what they contribute to a new project scaffold. `/bootstrap` reads these sections to generate files. Conventions without a `## Bootstrap` section are skipped during scaffolding but remain available for feature work.

`/bootstrap` reads all conventions to generate a project. `/implement` reads the relevant ones per task (matched by title or keywords). `/research` scans them to produce context for planning. Edit them to evolve your conventions.

## Documentation

After any config, tool, or script change, run `/document` to sync all docs.
