# Getting Started

Get comfortable with the tools before diving into the workflow. This guide covers terminal setup, navigation, and the utilities that ship with devenv.

> New here? Run `./install.sh` first — see [SETUP.md](../SETUP.md).

---

## Your Terminal: Ghostty

Everything runs in **Ghostty** — a fast, GPU-accelerated terminal with native split panes. No tmux needed.

### Panes

| Key | Action |
|-----|--------|
| `Cmd+Shift+Arrow` | Split in that direction |
| `Cmd+Arrow` | Navigate between panes |
| `Cmd+X` | Close pane |

A typical layout: Claude on the left, a shell on the right for running commands or watching output.

![Two vertical panes in Ghostty](screen-caps/01-panes.png)

### Project Picker

Press `Cmd+P` to open a new terminal tab at a project directory. This uses Ghostty's built-in quick terminal with fzf.

To configure which directories are searched, edit the keybind in `ghostty/config`. The default searches `~/Documents/personal` and `~/Documents/work`:

```
keybind = super+p=new_tab:zsh -c "cd $(find ~/Documents/personal ~/Documents/work -maxdepth 1 -type d | fzf) && exec zsh"
```

Add or remove paths to match where you keep your projects.

---

## Shell: Zsh + Starship

The prompt is powered by **Starship** — it shows git branch, language versions, and status icons at a glance. Config lives in `starship/starship.toml`.

### Key Shortcuts

| Key | Action |
|-----|--------|
| `Ctrl+P` | Fuzzy project picker (cd to project) |

The `Ctrl+P` widget searches the same directories as the Ghostty picker but stays in the current pane. Configure the search paths in `zsh/conf.d/40-widgets.zsh`.

### Aliases

| Alias | Expands to |
|-------|-----------|
| `ls` | `ls -1F` |
| `zshconfig` | Opens `~/.zshrc` in your editor |

### Local Config

Put machine-specific config (API keys, work paths, tool overrides) in `~/.zshrc.local`. It's sourced automatically and not tracked by git.

---

## Cheatsheet

Run `cheat` from anywhere to see the full cheatsheet:

```bash
cheat           # full cheatsheet
cheat ls        # list tool-specific sheets
cheat ghostty   # ghostty key bindings
```

The cheatsheet is a markdown file rendered with **glow**. All docs in `docs/` are symlinked to `~/.local/share/cheat/` so the `cheat` command can find them.

---

## Viewer Scripts

Four viewer scripts browse work artifacts saved by Claude skills. All use **fzf** for selection and **glow** for rendering.

| Command | Reads from |
|---------|-----------|
| `view-plan` | `.work/plans/` |
| `view-design` | `.work/designs/` |
| `view-implement` | `.work/implementations/` |
| `view-research` | `.work/research/` |

Pass a filename to view directly, or run with no args for the picker.

`open-diagrams <design-file>` opens `.mmd` architecture diagrams from a design doc in the browser, rendered with Mermaid.

These won't show anything until you've run the workflow skills — see the [Workflow Guide](workflow-guide.md).

---

## Configuration

### devenv.json

Skill config lives in `claude/devenv.json` (symlinked to `~/.claude/devenv.json`):

```json
{
  "work": { "dir": ".work" },
  "backups": { "maxPerArtifact": 5 },
  "rebase": { "defaultBase": "origin/master" },
  "conventions": {
    "layers": ["~/.claude/skills/conventions"]
  }
}
```

- `work.dir` — where skills save artifacts (relative to your project)
- `backups.maxPerArtifact` — how many backup copies to keep when refining plans/designs
- `conventions.layers` — ordered paths to convention doc directories (first match wins)

### Adding Config

To add a new dotfile to devenv:

1. Create a file with a `.symlink` extension (e.g., `git/gitconfig.symlink`)
2. Run `./install.sh` — it links `*.symlink` files to `~/.<name>`
3. Run `./verify.sh` to confirm

For tools with complex layouts (like Ghostty or Claude), there's a dedicated `install_*()` function in `install.sh`.

---

## Verifying the Install

```bash
./verify.sh
```

Checks all symlinks, bin scripts, and dependencies. Run it after any change to confirm everything is wired up.

---

## Next Steps

Ready to use the AI workflow? Read the [Workflow Guide](workflow-guide.md).
