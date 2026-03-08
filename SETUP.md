# Setup

> Tested on macOS only.

## Prerequisites

### 1. Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Clone and install

`install.sh` handles all dependencies automatically via the Brewfile:

| Tool | Purpose |
|---|---|
| `jq` | JSON processing (used by bin scripts and claude-context) |
| `fzf` | Fuzzy finder (project picker, plan/design viewers) |
| `glow` | Markdown renderer (cheat, viewer scripts) |
| `starship` | Shell prompt |
| `gh` | GitHub CLI |
| `shellcheck` | Shell script linter (pre-commit hook) |
| `shfmt` | Shell script formatter (pre-commit hook) |
| `gradle` | Build tool (`/bootstrap` generates Gradle wrapper) |
| `bun` | JS runtime (`bunx ccusage` for cost tracking) |
| `ghostty` | Terminal emulator |
| `claude-code` | Claude Code CLI |
| `font-jetbrains-mono-nerd-font` | Nerd font (icons in terminal) |

## Install devenv

```bash
git clone <your-repo-url> ~/Documents/personal/devenv
cd ~/Documents/personal/devenv
./install.sh
```

## After install

```bash
./verify.sh
```

Restart your terminal. Everything should be wired up — Ghostty config, zsh with Starship prompt, and the `ctrl+p` project picker.

## Troubleshooting

**`font-jetbrains-mono-nerd-font` not found**

On Homebrew older than 4.x, cask fonts live in a separate tap. Add it manually:

```bash
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
```
