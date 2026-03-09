---
name: bootstrap
description: Scaffold a project from conventions. Use when the user wants to start a new project.
argument-hint: "<project-name> [description]"
allowed-tools: Read Write Bash
---

Scaffold a new project driven entirely by resolved convention docs.

## Config

Read `~/.claude/devenv.json`. Key: `work.dir` (default `.work`).

## Resolve conventions

Run `/resolve-conventions mode:all scope:bootstrap` to resolve every convention that applies at bootstrap time. Read all resolved docs.

If `/resolve-conventions` is unavailable, warn the user: "Convention resolution skill not found — conventions will not be applied. Run install.sh from your devenv repo to fix this." Then stop.

If no conventions are resolved, stop: "No conventions found. Add at least a `stack.md` to `~/.claude/conventions/`, or install a convention pack from [devenv-conventions](https://github.com/minusblindfold/devenv-conventions). See `~/.claude/conventions/conventions.md` for the format."

Look for a **Stack** convention (matched by H1 title or `stack` keyword). If no stack convention is found, stop: "No stack convention found. Bootstrap needs a stack convention to know what kind of project to generate."

## Gather inputs

1. Parse `$ARGUMENTS` for the project name (first word) and optional description (rest). If no project name, ask.
2. From the stack convention, identify the technology stack and present a summary to the user.
3. Ask for any missing inputs. Wait for answers before generating. Only ask what the resolved conventions make relevant:
   - **Description**: one sentence — what the app does and why. (Skip if provided in arguments.)
   - If security conventions are present and define a role model, ask for **domain role name(s)**.
   - If the stack convention uses packages or modules, ask for the **root namespace/group**.
4. Confirm inputs with the user before generating.

## Generate project

Create all files in the **current working directory**. The directory should be empty or near-empty. If not empty, warn the user and ask to confirm.

### Skeleton

Read the stack convention fully. Generate the project skeleton it describes: build file, settings, config files, main entry point, wrapper, gitignore, and test config. Derive names (database name, package name, artifact name) from the project name.

### Convention contributions

Work through each remaining resolved convention that has a `## Bootstrap` section. Process them in natural dependency order: infrastructure → data layer → security → business logic → UI.

For each convention:
1. Read the full convention doc (rules, examples, and bootstrap section).
2. Generate the files its bootstrap section describes, following the convention's rules and examples exactly.
3. If a convention references another convention's output (e.g., templates reference security roles), ensure the dependency was generated first.

Skip conventions that have no `## Bootstrap` section — they apply during feature work, not scaffolding.

### Project documentation

Generate a `CLAUDE.md` tailored to the project. Derive everything from what was actually generated:
- Project overview (name, description, tech stack from stack convention).
- Common commands (build, run, test — from stack convention's startup section).
- Architecture overview (layers, security config, database, frontend — from the conventions that were applied).

## Write bootstrap context marker

Create `<work.dir>/bootstrap.md` in the project directory. Assemble it dynamically from what was resolved and generated:

```markdown
# Bootstrap Context

## Tech Stack
- <derived from stack convention>

## Roles
- <from user input, if applicable>

## Scaffolded Entities
- <list what was generated>

## What's Ready
- <list capabilities the scaffold provides>

## Conventions Applied
- <list each convention title and its source layer>
```

This marker is read by `/plan` and `/design` to skip redundant questions about established architecture.

## Wrap up

1. Print a summary of what was generated (file count by category).
2. Suggest next steps derived from the stack convention's startup section:
   - How to start the app.
   - Default credentials if seed users were generated.
   - Commit the initial scaffold.
   - Run `/plan` to start building features.

## Rules

- Never generate features beyond the minimal scaffold — that's what `/plan` → `/design` → `/implement` is for.
- Follow convention docs exactly. If a pattern isn't covered by a convention doc, keep it simple and consistent with the conventions that do exist.
- No hardcoded version numbers in generated code. Use latest stable versions at generation time.
- The bootstrap context marker goes in the project's `<work.dir>/`, not in devenv.
- Never hardcode technology choices in this skill. Every file generated must trace back to a resolved convention.
- If no conventions are resolved, do not guess a stack. Stop and tell the user.
