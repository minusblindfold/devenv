# devenv

Personal dev environment managed with symlinks via `install.sh`.

## Architecture

Two symlink patterns:
- **`.symlink` convention**: Files named `*.symlink` get linked to `~/.<name>` automatically.
- **Per-tool functions**: Tools with complex layouts have `install_*()` functions in `install.sh`.

Scripts in `bin/` use `#!/usr/bin/env bash` and are symlinked to `~/.local/bin/`.

## Claude Code

### Personal config

`claude/` contains personal Claude Code configuration (symlinked to `~/.claude/`):
- `CLAUDE.md` — global instructions (git preferences, devloop reference)
- `settings.json` — hooks and statusline config
- `hooks/log-activity.sh` — activity logging hook

### Devloop plugin

Workflow skills (`/dl:research`, `/dl:plan`, `/dl:design`, `/dl:implement`, `/dl:bootstrap`) are provided by the [devloop](https://github.com/minusblindfold/devloop) plugin, installed via `install_devloop()` in `install.sh`. The plugin is distributed as a Claude Code marketplace plugin.

### Bin scripts

Terminal companion tools for browsing devloop artifacts:
- `view-plan`, `view-design`, `view-implement`, `view-research` — browse `.work/` artifacts with fzf + glow
- `open-diagrams` — open `.mmd` diagrams in browser
- `claude-context` — statusline showing directory, git branch, context %, session cost

## Documentation

After any config, tool, or script change, run `/dl:document` to sync devloop docs, then update devenv docs manually.
