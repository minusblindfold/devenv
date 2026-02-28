# devenv

My personal dev environment configuration. Managed with a hand-rolled install script using symlinks.

## Structure

```
devenv/
├── bin/                    # Personal scripts → symlinked to ~/.local/bin/
├── claude/                 # Claude Code config → symlinked to ~/.claude/
│   └── settings.json
├── docs/                   # Cheatsheets → symlinked to ~/.local/share/cheat/
├── ghostty/                # Ghostty terminal config → symlinked to ~/.config/ghostty/
│   └── config
├── git-hooks/              # Global git hooks → symlinked to ~/.git-hooks/
├── home/                   # Dotfiles (*.symlink) → symlinked to ~/
├── starship/               # Starship prompt config → symlinked to ~/.config/
│   └── starship.toml
├── zsh/
│   └── zshrc.symlink       # → ~/.zshrc
├── install.sh              # Sets up all symlinks
├── verify.sh               # Post-install verification
└── .gitignore
```

Work-specific config and secrets live in `~/.zshrc.local` (not tracked). The tracked `.zshrc` sources it automatically if present.

**Convention:** Any file ending in `.symlink` gets linked into `$HOME` with a dot prefix.

Scripts in `bin/` are symlinked to `~/.local/bin/` and made executable.

## Install

```bash
./install.sh
```

The install script is **idempotent** — safe to run multiple times. It will:
- Symlink all `.symlink` files into `$HOME`
- Symlink `ghostty/config` into `~/.config/ghostty/`
- Symlink `starship/starship.toml` into `~/.config/`
- Symlink `claude/` config into `~/.claude/`
- Symlink `docs/` into `~/.local/share/cheat/`
- Symlink all `bin/` scripts into `~/.local/bin/`
- Symlink `git-hooks/` into `~/.git-hooks/` and set `core.hooksPath`
- Back up any existing files to `~/.dotfiles_backup/<timestamp>/` before replacing them
- Ensure `~/.local/bin` is in your `$PATH`

## Adding new config

1. Create a topic folder (e.g. `git/`, `vim/`)
2. Add your config file with a `.symlink` extension (e.g. `git/gitconfig.symlink`)
3. Run `./install.sh` to apply

## Tools

| Tool | Config |
|---|---|
| Ghostty | `ghostty/config` |
| zsh | `zsh/zshrc.symlink` |
| Starship | `starship/starship.toml` |
| Claude Code | `claude/settings.json` |
| Git hooks | `git-hooks/post-commit` |
