# Rules

Rules are markdown files that guide Claude Code skills (`/research`, `/plan`, `/design`, `/implement`, `/bootstrap`). Drop `.md` files into this directory and skills will discover them automatically.

## How this relates to Claude Code's native rules

Claude Code natively loads all `.md` files in `~/.claude/rules/` into every session — no filtering, no configuration. That works well for general instructions.

This system extends native rules with **skill-aware discovery**: frontmatter fields (`keywords`, `scope`, `extends`) that let skills find and apply only the rules relevant to the current task. These fields are read by the `/resolve-rules` skill — Claude Code itself ignores them (it treats frontmatter as regular text).

**What this means in practice:**
- Any rule file you drop here is loaded by Claude Code automatically (native behavior).
- Skills like `/research` and `/implement` also discover rules, but filter by keyword and scope so they surface only what's relevant.
- Rule packs (managed by [devenv-rules](https://github.com/minusblindfold/devenv-rules)) live in separate directories outside `~/.claude/rules/` and are only discovered by `/resolve-rules` — Claude Code doesn't auto-load them.

**Don't confuse with Claude Code's `paths:` frontmatter.** Native rules support a `paths:` field that controls which files trigger the rule to load (e.g., `paths: ["src/**/*.ts"]`). That's file-glob scoping — different from this system's `scope:` field, which controls workflow phase (bootstrap vs feature work). You can use both in the same file if needed.

## Format

Each rule file has YAML frontmatter followed by markdown content:

```markdown
---
keywords: [service, business logic, validation]
scope: all
extends: false
---
# Service Layer Rules

> One-line description of what this rule covers.

## Rules

- Rule one — what to do and why.
- Rule two — constraints or patterns to follow.

## Bootstrap

What this rule contributes when scaffolding a new project.
Omit this section if the rule only applies during feature work.

## Example

A concrete code example showing the rule in practice.
```

### Frontmatter fields

| Field | Required | Values | Description |
|---|---|---|---|
| `keywords` | Yes | Array of strings | Terms for keyword-based discovery. Skills match task descriptions against these. |
| `scope` | No | `bootstrap`, `feature`, `all` | When this rule applies. Default: `all`. |
| `extends` | No | `true`, `false` | If true, appends to a higher-precedence version instead of being overridden. Default: `false`. |

These fields are for the `/resolve-rules` skill. Claude Code ignores them — it loads the file regardless.

### Sections

- **`## Rules`** — The core patterns and constraints. This is what skills follow during implementation.
- **`## Bootstrap`** — What this rule contributes to a new project scaffold. `/bootstrap` reads these sections. Omit if the rule only matters during feature work.
- **`## Example`** — A concrete code sample. Helps the model understand the pattern in practice.

## Getting started

Create a `stack.md` to define your project skeleton (language, framework, build tool). This is the anchor rule — `/bootstrap` requires it to scaffold a project.

Add more rules as needed: one per concern (e.g., `entity.md`, `service.md`, `controller.md`, `testing.md`).

## Rule packs

For organized, reusable rule sets with management tooling, see [devenv-rules](https://github.com/minusblindfold/devenv-rules). Packs live in their own directories (not in `~/.claude/rules/`) and are discovered by `/resolve-rules` via a layers file. This means they're only surfaced to skills when relevant — Claude Code doesn't auto-load them into every session.
