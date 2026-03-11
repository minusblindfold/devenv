# Global Claude Code Instructions

## Git
Never include "Co-Authored-By" lines in commit messages.

## Dev Environment Skills
Personal skills are installed via the `devenv` repo and available in all projects:
- `/research` — scan rules and codebase to produce structured context
- `/plan` — create or refine a task list
- `/design` — generate a design doc from a plan
- `/implement` — implement a task from a plan+design pair
- `/bootstrap` — scaffold a new project from rules
- `/document` — sync documentation after changes

The typical flow is: `/research` → `/plan` → `/design` → `/implement`. `/bootstrap` is for new projects only. `/research` can re-enter at any stage.

Shared rules live in `~/.claude/rules/` and are resolved automatically by skills. Skill config lives in `~/.claude/devenv.json`.
