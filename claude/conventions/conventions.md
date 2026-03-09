# Convention Docs

Conventions are markdown files that guide Claude Code skills (`/plan`, `/design`, `/implement`, `/bootstrap`, `/research`). Drop `.md` files into this directory and skills will discover them automatically.

## Format

Each convention file has YAML frontmatter followed by markdown content:

```markdown
---
keywords: [service, business logic, validation]
scope: all
extends: false
---
# Service Layer Conventions

> One-line description of what this convention covers.

## Rules

- Rule one — what to do and why.
- Rule two — constraints or patterns to follow.

## Bootstrap

What this convention contributes when scaffolding a new project.
Omit this section if the convention only applies during feature work.

## Example

A concrete code example showing the convention in practice.
```

### Frontmatter fields

| Field | Required | Values | Description |
|---|---|---|---|
| `keywords` | Yes | Array of strings | Terms for keyword-based discovery. Skills match task descriptions against these. |
| `scope` | No | `bootstrap`, `feature`, `all` | When this convention applies. Default: `all`. |
| `extends` | No | `true`, `false` | If true, appends to a higher-precedence version instead of being overridden. Default: `false`. |

### Sections

- **`## Rules`** — The core patterns and constraints. This is what skills follow during implementation.
- **`## Bootstrap`** — What this convention contributes to a new project scaffold. `/bootstrap` reads these sections. Omit if the convention only matters during feature work.
- **`## Example`** — A concrete code sample. Helps the model understand the pattern in practice.

## Getting started

Create a `stack.md` to define your project skeleton (language, framework, build tool). This is the anchor convention — `/bootstrap` requires it to scaffold a project.

Add more conventions as needed: one per concern (e.g., `entity.md`, `service.md`, `controller.md`, `testing.md`).

## Convention packs

For organized, reusable convention sets with management tooling, see [devenv-conventions](https://github.com/minusblindfold/devenv-conventions). Packs extend this flat-file baseline with layered resolution and a CLI for enabling/disabling convention sets.
