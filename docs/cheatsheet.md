# Cheatsheet

## Install

```bash
git clone <repo-url> ~/path/of/your/choice
cd ~/path/of/your/choice && ./install.sh
./verify.sh
```

Dependencies are installed automatically via the Brewfile. See [SETUP.md](../SETUP.md) for details.

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

Prompt: **Starship** — git status, languages, icons.

## Git

| Command | Action |
|---------|--------|

## Claude

| Command | Action |
|---------|--------|
| `work-as <name> [args]` | Launch as named agent |
| `watch-agents` | Tail log, color by agent |
| `/plan [description\|slug]` | Create or refine a plan |
| `/design [slug]` | Generate HLD + specs from a plan, or refine an existing design |
| `/implement [slug [task-n]]` | Implement a task from a plan+design pair, save note to `.work/implementations/` |
| `/rebase [base-branch]` | Rebase current branch onto base (default: `rebase.defaultBase` in `devenv.json`); auto-resolves whitespace/additive conflicts |
| `/strip-fmt [--staged\|--unstaged]` | Strip accidental formatting noise from the diff, preserving intentional changes |

Git commits and tool activity are logged to `~/.claude/activity.log` via hooks. Activity logging only runs during `work-as` sessions.

Work artifacts (plans, designs, implementations, backups) are saved to `.work/` — add `.work/` to each project's `.gitignore`.

Skills (`/plan`, `/design`, `/implement`) live in `claude/skills/`, symlinked to `~/.claude/skills/`. Commands (`/document`, `/rebase`, `/strip-fmt`) live in `claude/commands/`.

Skill config lives in `~/.claude/devenv.json` (symlinked from `claude/devenv.json` in this repo). Key settings: `work.dir` (default `.work`), `backups.maxPerArtifact`, `rebase.defaultBase` (default `origin/master`).

## CLI

### `cheat`

| Command | Action |
|---------|--------|
| `cheat` | Show this cheatsheet |
| `cheat help` | Same as above |
| `cheat ls` | List tool cheatsheets |
| `cheat <tool>` | View tool cheatsheet |

### `todo`

| Command | Action |
|---------|--------|
| `todo add <text>` | Add a todo |
| `todo ls` | List todos |
| `todo x` | Toggle done |
| `todo rm` | Remove |
| `todo rm <n>` | Remove by number |
| `todo clear` | Clear completed |

Stored in `~/todo.md`.

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

Reads from `.work/plans/`, `.work/designs/`, and `.work/implementations/` in the current project.

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
