# devenv

Personal dev environment managed with symlinks via `install.sh`.

## Architecture

Two symlink patterns:
- **`.symlink` convention**: Files named `*.symlink` get linked to `~/.<name>` automatically.
- **Per-tool functions**: Tools with complex layouts have `install_*()` functions in `install.sh`.

Scripts in `bin/` use `#!/usr/bin/env bash` and are symlinked to `~/.local/bin/`.

## Documentation

After any config, tool, or script change, run `/document` to sync all docs.
