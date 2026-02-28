# Setup

> Tested on macOS only.

## Prerequisites

### 1. Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Brew dependencies

| Tool | Purpose |
|---|---|
| `git` | Version control |
| `fzf` | Fuzzy finder |
| `glow` | Markdown renderer |
| `starship` | Shell prompt |
| `ghostty` | Terminal emulator |
| `claude-code` | AI assistant |
| `font-jetbrains-mono-nerd-font` | Nerd font |

```bash
brew install git fzf glow starship
brew install --cask ghostty claude-code font-jetbrains-mono-nerd-font
```

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
