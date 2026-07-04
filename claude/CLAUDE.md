# Global Claude Code Instructions

## Git
Never include "Co-Authored-By" lines in commit messages.

## Workflow Skills
Skills are provided by the [devloop](https://github.com/minusblindfold/devloop) plugin. Run `/dl:brainstorm` to get started.

## Workflow
When executing multi-step workflow pipelines (brainstorm→research→plan→design→implement→review), always continue to the next step automatically without pausing for user confirmation unless explicitly told to stop.

## Git Operations
When working across two repos (devloop plugin + companion repo), always verify which branch you're on before committing. Never commit to the wrong branch.

## Environment
This is a macOS/BSD environment. Use `sed -i '' ...` (BSD sed) instead of `sed -i ...` (GNU sed) for in-place edits.
