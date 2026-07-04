#!/usr/bin/env bash
# Blocks git commit on main/master — enforces feature-branch workflow.
set -uo pipefail

# Guard: jq required
command -v jq &>/dev/null || exit 0

# Read hook input
input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty')

# Only check git commit commands
[[ "$cmd" =~ git[[:space:]]+commit ]] || exit 0

# Resolve the directory the command actually targets — a leading `cd <dir> &&`/`cd <dir> ;`
# prefix, or a `git -C <dir>` flag — so multi-repo commands (e.g. `cd ../other-repo && git
# commit ...`) are checked against the right repo instead of this hook's own invocation cwd.
target_dir=""
if [[ "$cmd" =~ ^[[:space:]]*cd[[:space:]]+([^[:space:]\&\;]+)[[:space:]]*(\&\&|\;) ]]; then
  target_dir="${BASH_REMATCH[1]}"
elif [[ "$cmd" =~ git[[:space:]]+-C[[:space:]]+([^[:space:]]+) ]]; then
  target_dir="${BASH_REMATCH[1]}"
fi

# Strip surrounding quotes and expand a leading ~
target_dir="${target_dir%\"}"
target_dir="${target_dir#\"}"
target_dir="${target_dir%\'}"
target_dir="${target_dir#\'}"
target_dir="${target_dir/#\~/$HOME}"

git_dir_args=()
[[ -n "$target_dir" ]] && git_dir_args=(-C "$target_dir")

# Guard: must be in a git repo
git "${git_dir_args[@]}" rev-parse --git-dir &>/dev/null 2>&1 || exit 0

# Check current branch
branch=$(git "${git_dir_args[@]}" rev-parse --abbrev-ref HEAD 2>/dev/null)
case "$branch" in
main | master)
  echo "Blocked: cannot commit directly to $branch. Create a feature/<slug> branch first." >&2
  exit 2
  ;;
esac

exit 0
