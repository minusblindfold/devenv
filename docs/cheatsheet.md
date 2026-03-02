# Cheatsheet

## Install

```bash
brew install git fzf glow starship jq
brew install --cask ghostty claude-code font-jetbrains-mono-nerd-font
git clone <repo-url> ~/path/of/your/choice
cd ~/path/of/your/choice && ./install.sh
./verify.sh
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

Prompt: **Starship** — git status, languages, icons.

## Git

| Command | Action |
|---------|--------|
| `gclb <url>` | Clone bare repo + worktree |

## Claude

| Command | Action |
|---------|--------|
| `work-as <name> [args]` | Launch as named agent |
| `watch-agents` | Tail log, color by agent |

Git commits and tool activity are logged to `~/.claude/activity.log` via hooks. Activity logging only runs during `work-as` sessions.

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

## Local Config

`~/.zshrc.local` — work-specific, not tracked, sourced automatically.
