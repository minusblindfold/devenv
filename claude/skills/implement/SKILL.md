---
name: implement
description: Implement a task from a plan and design. Use when the user wants to start coding a planned feature or work through tasks one at a time.
argument-hint: "[plan-slug] [task-number]"
allowed-tools: Read Write Edit Bash(git:*) TaskCreate TaskList TaskUpdate
---

Implement one task from a plan+design pair.

## Config

Read `~/.claude/devenv.json`. Key: `work.dir` (default `.work`).

## Find the feature

If $ARGUMENTS: treat as `<slug>` or `<slug> <task-N>`. Find plan in `<work.dir>/plans/`, then matching design in `<work.dir>/designs/`. Missing design → "No design found for '<slug>'. Run /design first." and stop.
If no argument: list plans and designs, match by slug. No pairs → "Run /plan then /design first." and stop. One pair → auto-select. Many → ask.

## Load and sync

1. Read both files in full.
2. Read any `.mmd` diagrams referenced in the design from `<work.dir>/designs/diagrams/`. Use them to understand the proposed architecture and flow before implementing.
3. Check `.claude/skills/` for available skills. Print what's found.
4. Sync plan tasks to Claude Code task list: call `TaskList`, then `TaskCreate` for any task not already present.
5. Print task list with completion status.

## Pick a task

If $ARGUMENTS includes a task number, use it. Otherwise ask. Warn if dependencies are incomplete. Mark `in_progress` with `TaskUpdate`.

## Implement

1. Read all relevant files before editing.
2. Run relevant tests if available to establish a baseline.
3. Implement against the task spec (Goal, Interfaces, Acceptance criteria from the design).
4. Use available skills where applicable.
5. Re-run tests. Note any failures or unexpected results.
6. Mark `completed` with `TaskUpdate` when fully done.

## Wrap up

- Summarise changes (files created/modified).
- Note any deviations from the design spec — interfaces, structures, or approaches that changed. If significant, suggest running `/design` refine before the next task.
- If out-of-scope work was discovered, suggest running `/plan` refine to capture it.
- Suggest a git commit scoped to this task.
- Recommend follow-up skills — only skills found in `.claude/skills/`.
- Save an implementation note — see [implementation-note.md](implementation-note.md).

## Rules

- Never start without a design file.
- Never duplicate tasks — match by subject before creating.
- Implement only the selected task. Note out-of-scope discoveries in the implementation note rather than acting on them.
- Save the implementation note even if the task is incomplete.
