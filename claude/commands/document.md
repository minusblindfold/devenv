Review the changes made in this session and update all documentation to match.

## Config to cheatsheet mapping

- `ghostty/` → `docs/ghostty-cheatsheet.md` + Ghostty section in `docs/cheatsheet.md`
- `zsh/` → Shell section in `docs/cheatsheet.md`
- `claude/` → Claude section in `docs/cheatsheet.md`
- `git-hooks/` → Git section in `docs/cheatsheet.md`
- `bin/cheat` → CLI > cheat section in `docs/cheatsheet.md`
- `bin/view-plan` → CLI > view-plan section in `docs/cheatsheet.md`
- `bin/view-design` → CLI > view-design section in `docs/cheatsheet.md`
- `bin/view-implement` → CLI > view-implement section in `docs/cheatsheet.md`
- `claude/skills/implement/SKILL.md` → Claude section in `docs/cheatsheet.md`
- `claude/skills/plan/SKILL.md` → Claude section in `docs/cheatsheet.md` *(create + refine mode)*
- `claude/skills/design/SKILL.md` → Claude section in `docs/cheatsheet.md` *(create, bootstrap + refine mode)*
- `claude/devenv.json` → Claude section in `docs/cheatsheet.md` (skill config location)
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
- New Claude skill → add to Claude table in `docs/cheatsheet.md` and `README.md` Tools table
- New dependency → add to all three dependency sources above
- `.work/implementations/` is produced by `/implement` — note in `README.md` structure tree if not already present
- `.work/plans/.backup/` and `.work/designs/.backup/` are auto-created by refine mode — note in `README.md` that `.work/` subdirs may contain a `.backup/` folder

## Final check

Run `./verify.sh` and confirm all checks pass.
