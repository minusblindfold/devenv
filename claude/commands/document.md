Review the changes made in this session and update all documentation to match.

## Config to cheatsheet mapping

- `ghostty/` → `docs/ghostty-cheatsheet.md` + Ghostty section in `docs/cheatsheet.md`
- `zsh/` → Shell section in `docs/cheatsheet.md`
- `claude/` → Claude section in `docs/cheatsheet.md`
- `git-hooks/` → Git section in `docs/cheatsheet.md`
- `bin/cheat` → CLI > cheat section in `docs/cheatsheet.md`
- `bin/todo` → CLI > todo section in `docs/cheatsheet.md` + `docs/todo-cheatsheet.md`
- `starship/` → Shell section in `docs/cheatsheet.md`

## Dependency sync

These three files must stay in sync when dependencies change:
- `SETUP.md` — brew dependencies table and install commands
- `docs/cheatsheet.md` — install code block
- `verify.sh` — `check_cmd` calls

## Structural sync

- New directory or tool → add to `README.md` structure tree and Tools table
- New symlink → add `install_*()` in `install.sh` + `check_link` in `verify.sh`
- New bin script → add CLI entry in `docs/cheatsheet.md`
- New dependency → add to all three dependency sources above

## Final check

Run `./verify.sh` and confirm all checks pass.
