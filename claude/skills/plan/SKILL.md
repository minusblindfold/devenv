---
name: plan
description: Plan a feature as a task list. Use when the user wants to plan, decompose, or organise work.
argument-hint: "[feature description]"
allowed-tools: Read Write Bash TaskCreate
---

Create or refine a feature plan.

## Config

Read `~/.claude/devenv.json`. Keys: `work.dir` (default `.work`), `backups.maxPerArtifact` (default 5, applies to refine mode only).

## Mode

If $ARGUMENTS matches a file in `<work.dir>/plans/` by exact filename or unambiguous prefix → refine mode. If ambiguous, list matches and ask.
If $ARGUMENTS is set → create mode using it as the feature description.
If $ARGUMENTS is empty → list `<work.dir>/plans/`. None: ask what to plan. One: offer refine or new. Many: numbered list, ask to pick or describe a new feature.

## Create mode

1. Explore: read `CLAUDE.md`, scan directory, check `.claude/skills/` for available skills.
2. Ask 3–5 clarifying questions (what, stack if unclear, scope, constraints). Wait for confirmation.
3. Create tasks with `TaskCreate`. Make them small, meaningful, and ordered by dependency.
4. Save plan to `<work.dir>/plans/YYYY-MM-DD-<slug>.md`.
5. Ask the user to review. Once confirmed, suggest running `/design` to architect the feature.

## Refine mode

1. Back up the current file — see [backup.md](../backup.md).
2. Show current plan.
3. Ask "What would you like to change?" Iterate until confirmed.
4. Write the updated file once.

## Plan format

```markdown
# <Feature Name>

> One sentence: what this feature does and why.

## Tasks

- [ ] **Task title** — what it does; key constraints or dependencies if any.
- [ ] ...
```

Tasks should be small and ordered by dependency. Each item needs enough detail for `/design` to write a full spec (goal, interfaces, acceptance criteria) without guessing.

## Rules

- Never implement.
- Only reference skills found in `.claude/skills/`.
- Right-size tasks — small over large.
- In refine mode, write once at the end.
