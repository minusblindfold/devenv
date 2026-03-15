# Cheatsheet

## Install

```bash
git clone <repo-url> ~/path/of/your/choice
cd ~/path/of/your/choice && ./install.sh
./verify.sh
```

Dependencies are installed automatically via the Brewfile.

## Uninstall

```bash
./uninstall.sh
```

## Terminal (Ghostty)

| Key | Action |
|-----|--------|
| `Cmd+Shift+Arrow` | New split |
| `Cmd+Arrow` | Navigate splits |
| `Cmd+X` | Close pane |
| `Cmd+P` | Project picker |

Dark Pastel, JetBrainsMono Nerd Font 14pt, bell disabled.

## Shell (Zsh)

| Command | Action |
|---------|--------|
| `Ctrl+P` | Project picker (`fzf`) |
| `ls` | `ls -1F` |
| `zshconfig` | Open `~/.zshrc` |
| `zshlocal` | Open `~/.zshrc.local` |

Prompt: **Starship** — git status, languages, icons.

## Git

| Hook | Action |
|------|--------|
| `pre-commit` | Runs shellcheck + shfmt on staged shell scripts (skips zsh) |

## Claude

| Command | Action |
|---------|--------|
| `work-as <name> [args]` | Launch as named agent |
| `watch-agents` | Tail log, color by agent |
| `/dl:research [slug\|topic]` | Scan rules + codebase for context, save to `.work/research/` |
| `/dl:plan [description\|slug]` | Create or refine a plan |
| `/dl:design [slug]` | Generate HLD + specs from a plan, or refine an existing design |
| `/dl:implement [slug [task-n]]` | Implement a task from a plan+design pair, save note to `.work/implementations/` |
| `/dl:bootstrap <project-name>` | Scaffold a project from rules |

Git commits and tool activity are logged to `~/.claude/activity.log` via hooks. Activity logging only runs during `work-as` sessions.

Work artifacts (plans, designs, implementations, backups) are saved to `.work/` — add `.work/` to each project's `.gitignore`.

Skills are provided by the [devloop](https://github.com/minusblindfold/devloop) plugin. Install via `claude plugin marketplace add minusblindfold/devloop && claude plugin install dl@devloop-marketplace`. Rule docs are discovered via `/dl:resolve-rules` across four layers: `~/.claude/rules/` (user) → `{cwd}/devloop/rules/` (project) → `~/devloop/rules/` (shared/org packs) → plugin-bundled.

## CLI

### `cheat`

| Command | Action |
|---------|--------|
| `cheat` | Show this cheatsheet |
| `cheat help` | Same as above |
| `cheat ls` | List tool cheatsheets |
| `cheat <tool>` | View tool cheatsheet |

### `view-research`

| Command | Action |
|---------|--------|
| `view-research` | Browse research files (fzf + glow) |
| `view-research <file>` | View a specific research file |

### `view-plan`

| Command | Action |
|---------|--------|
| `view-plan` | Browse plans (fzf + glow) |
| `view-plan <file>` | View a specific plan |

### `view-design`

| Command | Action |
|---------|--------|
| `view-design` | Browse designs (fzf + glow) |
| `view-design <file>` | View a specific design |
| `ctrl-d` (in picker) | Open `.mmd` diagrams for the selected design in the browser |

### `view-implement`

| Command | Action |
|---------|--------|
| `view-implement` | Browse implementation notes (fzf + glow) |
| `view-implement <file>` | View a specific implementation note |

### `open-diagrams`

| Command | Action |
|---------|--------|
| `open-diagrams <design-file>` | Open `.mmd` diagrams referenced in a design doc in the browser |

Reads from `.work/research/`, `.work/plans/`, `.work/designs/`, and `.work/implementations/` in the current project.

### `dl-refresh`

| Command | Action |
|---------|--------|
| `dl-refresh` | Clear plugin cache and reinstall the devloop plugin |

Restart Claude Code after running to pick up changes.

### `picker-paths`

| Command | Action |
|---------|--------|
| `picker-paths list` | Show configured picker paths |
| `picker-paths add <path>` | Add a root directory |
| `picker-paths remove <path>` | Remove a root directory |

Manages `~/.config/devenv/paths` — the list of root directories searched by the `Ctrl+P` project picker and `Cmd+P` Ghostty picker.

### `ccusage`

| Command | Action |
|---------|--------|
| `ccusage daily` | Show Claude API cost by day |
| `ccusage monthly` | Show cost by month |
| `ccusage session` | Show cost by session |
| `ccusage blocks` | Show cost by 5-hour billing block |

Alias for `bunx ccusage@latest`. Costs shown in the Claude Code statusline via `claude-context`.

## Local Config

`~/.zshrc.local` — work-specific, not tracked, sourced automatically.
