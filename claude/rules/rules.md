# Rules

Rules are markdown files that guide Claude Code skills (`/research`, `/plan`, `/design`, `/implement`, `/bootstrap`). Drop `.md` files into this directory and skills will discover them automatically.

This extends Claude Code's native `.claude/rules/` with frontmatter-based discovery — keywords, scoping, and layered resolution.

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

### Sections

- **`## Rules`** — The core patterns and constraints. This is what skills follow during implementation.
- **`## Bootstrap`** — What this rule contributes to a new project scaffold. `/bootstrap` reads these sections. Omit if the rule only matters during feature work.
- **`## Example`** — A concrete code sample. Helps the model understand the pattern in practice.

## Getting started

Create a `stack.md` to define your project skeleton (language, framework, build tool). This is the anchor rule — `/bootstrap` requires it to scaffold a project.

Add more rules as needed: one per concern (e.g., `entity.md`, `service.md`, `controller.md`, `testing.md`).

## Rule packs

For organized, reusable rule sets with management tooling, see [devenv-rules](https://github.com/minusblindfold/devenv-rules). Packs extend this flat-file baseline with layered resolution and a CLI for enabling/disabling rule sets.
