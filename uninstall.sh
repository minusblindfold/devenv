#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Logging ────────────────────────────────────────────────────────────────────
info() { echo "  [ .. ] $1"; }
ok() { echo "  [ ok ] $1"; }
warn() { echo "  [warn] $1"; }
skip() { echo "  [skip] $1"; }

# ── Unlink helper (only removes symlinks pointing into DOTFILES_DIR) ──────────
unlink_file() {
  local dst="$1"
  if [ -L "$dst" ]; then
    local target
    target="$(readlink "$dst")"
    if [[ "$target" == "$DOTFILES_DIR"* ]]; then
      rm "$dst"
      ok "Removed: $dst"
    else
      skip "Not a devenv link: $dst → $target"
    fi
  elif [ -e "$dst" ]; then
    skip "Real file, not a symlink: $dst"
  else
    skip "Already absent: $dst"
  fi
}

# ── Remove directory if empty ─────────────────────────────────────────────────
rmdir_if_empty() {
  local dir="$1"
  if [ -d "$dir" ] && [ -z "$(ls -A "$dir")" ]; then
    rmdir "$dir"
    ok "Removed empty dir: $dir"
  fi
}

# ── Uninstall zsh config ─────────────────────────────────────────────────────
uninstall_zsh() {
  info "Removing zsh config..."
  unlink_file "$HOME/.zsh/devenv.zsh"

  if [ -f "$HOME/.zshrc" ]; then
    sed -i '' '/devenv\.zsh/d' "$HOME/.zshrc"
    ok "Removed devenv source line from ~/.zshrc"
  fi

  rmdir_if_empty "$HOME/.zsh"
}

# ── Uninstall global git hooks ────────────────────────────────────────────────
uninstall_git_hooks() {
  info "Removing global git hooks..."

  for src in "$DOTFILES_DIR/git-hooks/"*; do
    [ -f "$src" ] || continue
    unlink_file "$HOME/.git-hooks/$(basename "$src")"
  done

  rmdir_if_empty "$HOME/.git-hooks"

  local current
  current="$(git config --global core.hooksPath 2>/dev/null || true)"
  if [ "$current" = "$HOME/.git-hooks" ]; then
    git config --global --unset core.hooksPath
    ok "Unset global core.hooksPath"
  fi
}

# ── Uninstall bin/ scripts ────────────────────────────────────────────────────
uninstall_bin() {
  info "Removing bin scripts..."

  for src in "$DOTFILES_DIR/bin/"*; do
    [ -f "$src" ] || continue
    unlink_file "$HOME/.local/bin/$(basename "$src")"
  done
}

# ── Uninstall cheat docs ─────────────────────────────────────────────────────
uninstall_cheat() {
  info "Removing cheat docs..."
  unlink_file "$HOME/.local/share/cheat"
}

# ── Uninstall picker config ──────────────────────────────────────────────────
uninstall_picker() {
  info "Removing picker config..."
  unlink_file "$HOME/.config/devenv/paths"
  rmdir_if_empty "$HOME/.config/devenv"
}

# ── Uninstall devloop plugin ─────────────────────────────────────────────────
uninstall_devloop() {
  info "Removing devloop plugin..."
  if command -v claude &>/dev/null; then
    if claude plugin uninstall dl 2>/dev/null; then
      ok "devloop plugin uninstalled"
    else
      warn "devloop plugin uninstall failed (may already be removed)"
    fi
  else
    skip "Claude Code not found"
  fi
}

# ── Uninstall Claude Code config ─────────────────────────────────────────────
uninstall_claude() {
  info "Removing Claude Code config..."

  for src in "$DOTFILES_DIR/claude/hooks/"*; do
    [ -f "$src" ] || continue
    unlink_file "$HOME/.claude/hooks/$(basename "$src")"
  done

  rmdir_if_empty "$HOME/.claude/hooks"

  unlink_file "$HOME/.claude/CLAUDE.md"
  unlink_file "$HOME/.claude/settings.json"
}

# ── Uninstall Ghostty config ─────────────────────────────────────────────────
uninstall_ghostty() {
  info "Removing Ghostty config..."

  for src in "$DOTFILES_DIR/ghostty/"*; do
    [ -f "$src" ] || continue
    unlink_file "$HOME/.config/ghostty/$(basename "$src")"
  done

  rmdir_if_empty "$HOME/.config/ghostty"
}

# ── Uninstall Starship config ────────────────────────────────────────────────
uninstall_starship() {
  info "Removing Starship config..."
  unlink_file "$HOME/.config/starship.toml"
}

# ── Uninstall .symlink files ─────────────────────────────────────────────────
uninstall_symlinks() {
  info "Removing symlinks..."

  while IFS= read -r -d '' src; do
    filename="$(basename "$src")"
    dst="$HOME/.${filename%.symlink}"
    unlink_file "$dst"
  done < <(find "$DOTFILES_DIR" -name "*.symlink" -not -path "*/.git/*" -print0)
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo "Uninstalling devenv from $DOTFILES_DIR"
  echo "────────────────────────────────────────"

  # Reverse order of install
  uninstall_zsh
  uninstall_git_hooks
  uninstall_bin
  uninstall_cheat
  uninstall_picker
  uninstall_devloop
  uninstall_claude
  uninstall_ghostty
  uninstall_starship
  uninstall_symlinks

  echo "────────────────────────────────────────"
  echo "  Done! Restart your terminal to apply changes."

  echo ""
  echo "  Notes:"
  echo "  - Homebrew packages were left in place (uninstall manually if needed)"
  if [ -d "$HOME/.dotfiles_backup" ]; then
    echo "  - Backup files exist at ~/.dotfiles_backup/"
  fi
  echo ""
}

main
