#!/usr/bin/env bash
# shellcheck disable=SC2088
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAIL_COUNT=0

pass() { echo "  [ ok ] $1"; }
fail() {
  echo "  [FAIL] $1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

# Check that a symlink exists and points to a real file
check_link() {
  local dst="$1" label="${2:-$1}"
  if [ -L "$dst" ] && [ -e "$dst" ]; then
    pass "$label"
  else
    fail "$label"
  fi
}

# Check that a command is on PATH
check_cmd() {
  if command -v "$1" &>/dev/null; then
    pass "$1 found"
  else
    fail "$1 not found"
  fi
}

echo ""
echo "Verifying devenv installation"
echo "────────────────────────────────────────"

# ── Symlinks ──────────────────────────────────────────────────────────────────
echo ""
echo "  Symlinks"
check_link "$HOME/.zsh/devenv.zsh" "~/.zsh/devenv.zsh"
check_link "$HOME/.hushlogin" "~/.hushlogin"
check_link "$HOME/.config/ghostty/config" "~/.config/ghostty/config"
check_link "$HOME/.config/starship.toml" "~/.config/starship.toml"
check_link "$HOME/.claude/settings.json" "~/.claude/settings.json"
check_link "$HOME/.claude/CLAUDE.md" "~/.claude/CLAUDE.md"
check_link "$HOME/.claude/hooks/log-activity.sh" "~/.claude/hooks/log-activity.sh"
# devloop plugin (installed via Claude Code plugin system)
if [ -d "$HOME/.claude/plugins/cache" ] && find "$HOME/.claude/plugins/cache" -maxdepth 2 -name "plugin.json" -exec grep -ql '"dl"' {} \; 2>/dev/null | head -1 | grep -q .; then
  pass "devloop plugin installed"
else
  echo "  [info] devloop plugin not found — install with: claude plugin install dl@devloop-marketplace"
fi
# Picker paths: symlink or user-customized real file are both valid
if [ -L "$HOME/.config/devenv/paths" ] || [ -f "$HOME/.config/devenv/paths" ]; then
  pass "~/.config/devenv/paths"
else
  fail "~/.config/devenv/paths"
fi
check_link "$HOME/.local/share/cheat" "~/.local/share/cheat"
check_link "$HOME/.git-hooks/post-commit" "~/.git-hooks/post-commit"

# ── Bin scripts ───────────────────────────────────────────────────────────────
echo ""
echo "  Bin scripts"
for src in "$DOTFILES_DIR/bin/"*; do
  [ -f "$src" ] || continue
  name="$(basename "$src")"
  dst="$HOME/.local/bin/$name"
  check_link "$dst" "~/.local/bin/$name"

  if [ -x "$src" ]; then
    pass "$name is executable"
  else
    fail "$name is not executable"
  fi

  if command -v "$name" &>/dev/null; then
    pass "$name on PATH"
  else
    fail "$name not on PATH"
  fi
done

# ── Dependencies ──────────────────────────────────────────────────────────────
echo ""
echo "  Dependencies"
check_cmd git
check_cmd fzf
check_cmd starship
check_cmd jq
check_cmd shellcheck
check_cmd shfmt
check_cmd bun
check_cmd claude
check_cmd glow

# ── Smoke tests ───────────────────────────────────────────────────────────────
echo ""
echo "  Smoke tests"

if cheat help &>/dev/null; then
  pass "cheat exits 0"
else
  fail "cheat exits non-zero"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "────────────────────────────────────────"
if [ "$FAIL_COUNT" -eq 0 ]; then
  echo "  All checks passed."
else
  echo "  $FAIL_COUNT check(s) failed."
fi
echo ""

exit "$([ "$FAIL_COUNT" -eq 0 ] && echo 0 || echo 1)"
