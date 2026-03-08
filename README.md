# devenv

> [!CAUTION]
> This is highly opinionated and intentionally simple. It's meant as an introduction to a development environment integrated with Claude Code — not a one-size-fits-all setup. Adapt it to your own workflow.

My personal dev environment configuration. Managed with a hand-rolled install script using symlinks.

→ **[Getting Started](docs/getting-started.md)** — terminal, tools, and configuration.
→ **[Workflow Guide](docs/workflow-guide.md)** — the `/research → /plan → /design → /implement` loop and harness engineering rationale.

## Structure

```
devenv/
├── bin/                    # Personal scripts → symlinked to ~/.local/bin/
│   ├── cheat               # Markdown cheatsheet viewer
│   ├── claude-context      # Claude Code statusline (directory, git branch, context %, session cost)
│   ├── view-plan           # Browse .work/plans/ with fzf + glow
│   ├── view-design         # Browse .work/designs/ with fzf + glow (ctrl-d opens diagrams)
│   ├── view-implement      # Browse .work/implementations/ with fzf + glow
│   ├── view-research       # Browse .work/research/ with fzf + glow
│   ├── open-diagrams       # Open .mmd diagrams for a design in the browser
│   └── picker-paths        # Manage project picker search paths
├── picker/                 # Project picker config → symlinked to ~/.config/devenv/
│   └── paths               # Root directories for ctrl+p / Cmd+P picker
├── claude/                 # Claude Code config → symlinked to ~/.claude/
│   ├── skills/             # Skills → each subdir symlinked to ~/.claude/skills/<name>/
│   │   ├── bootstrap/      # /bootstrap — scaffold a project from conventions
│   │   ├── research/       # /research — scan conventions + codebase for context
│   │   ├── plan/           # /plan — task planning
│   │   ├── design/         # /design — HLD + specs from a plan
│   │   ├── implement/      # /implement — drive task implementation from plan+design
│   │   └── resolve-conventions/  # Convention resolution (called by other skills, not user-invocable)
│   ├── conventions/        # Convention reference docs → symlinked to ~/.claude/conventions/
│   ├── commands/           # Commands (flat .md files)
│   │   ├── document.md     # /document — sync docs after changes
│   ├── hooks/
│   │   └── log-activity.sh
│   ├── CLAUDE.md
│   ├── devenv.json         # Skill config → symlinked to ~/.claude/devenv.json
│   └── settings.json
├── docs/                   # Cheatsheets → symlinked to ~/.local/share/cheat/
├── ghostty/                # Ghostty terminal config → symlinked to ~/.config/ghostty/
│   └── config
├── git-hooks/              # Global git hooks → symlinked to ~/.git-hooks/ (shellcheck + shfmt pre-commit)
├── home/                   # Dotfiles (*.symlink) → symlinked to ~/
├── starship/               # Starship prompt config → symlinked to ~/.config/
│   └── starship.toml
├── zsh/
│   ├── devenv.zsh          # Loader → symlinked to ~/.zsh/devenv.zsh
│   └── conf.d/             # Modular zsh config (sourced in order by devenv.zsh)
│       ├── 10-path.zsh
│       ├── 20-prompt.zsh
│       ├── 30-aliases.zsh
│       ├── 40-widgets.zsh
│       ├── 50-agents.zsh
│       └── 60-local.zsh
├── install.sh              # Sets up all symlinks
├── verify.sh               # Post-install verification
└── .gitignore
```

Work-specific config and secrets live in `~/.zshrc.local` (not tracked). `60-local.zsh` sources it automatically if present.

Claude skill config (backup limits, work dir, convention layers) lives in `claude/devenv.json`, symlinked to `~/.claude/devenv.json`. Work artifacts (`plans/`, `designs/`, `implementations/`, `research/`, and `.backup/` subdirs within each) are written to `.work/` in whatever project you're working in — add `.work/` to that project's `.gitignore`.

**Convention:** Any file ending in `.symlink` gets linked into `$HOME` with a dot prefix.

Scripts in `bin/` are symlinked to `~/.local/bin/` and made executable.

## Install

Clone the repo anywhere you like, then run the install script:

```bash
git clone <repo-url> ~/path/of/your/choice
cd ~/path/of/your/choice && ./install.sh
```

The repo path doesn't matter — the install script detects its own location at runtime and builds all symlinks relative to it. Dependencies (see `Brewfile`) are installed automatically. You'll be prompted once for your email for telemetry attribution.

The install script is **idempotent** — safe to run multiple times. It will:
- Symlink all `.symlink` files into `$HOME`
- Symlink `ghostty/config` into `~/.config/ghostty/`
- Symlink `starship/starship.toml` into `~/.config/`
- Symlink `claude/` config, hooks, and conventions into `~/.claude/`; each `claude/skills/<name>/` directory into `~/.claude/skills/<name>/`
- Symlink `picker/paths` into `~/.config/devenv/paths` (skipped if user has customized paths)
- Symlink `docs/` into `~/.local/share/cheat/`
- Symlink all `bin/` scripts into `~/.local/bin/`
- Symlink `git-hooks/` into `~/.git-hooks/` and set `core.hooksPath`
- Symlink `zsh/devenv.zsh` into `~/.zsh/devenv.zsh` and inject a `source` line into `~/.zshrc` (never replaces it)
- Back up any existing files to `~/.dotfiles_backup/<timestamp>/` before replacing them

## Adding new config

1. Create a topic folder (e.g. `git/`, `vim/`)
2. Add your config file with a `.symlink` extension (e.g. `git/gitconfig.symlink`)
3. Run `./install.sh` to apply

## Tools

| Tool | Config |
|---|---|
| Ghostty | `ghostty/config` |
| zsh | `zsh/devenv.zsh` (loader), `zsh/conf.d/` (modules) |
| Starship | `starship/starship.toml` |
| Claude Code | `claude/settings.json`, `claude/hooks/log-activity.sh`, `claude/skills/{plan,design,implement,bootstrap,research}/SKILL.md`, `claude/conventions/*.md`, `claude/skills/resolve-conventions/SKILL.md`, `claude/commands/document.md`, `claude/devenv.json` (skill config) |
| Git hooks | `git-hooks/pre-commit`, `git-hooks/post-commit` |
