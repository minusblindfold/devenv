#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# ── Logging ────────────────────────────────────────────────────────────────────
info()  { echo "  [ .. ] $1"; }
ok()    { echo "  [ ok ] $1"; }
warn()  { echo "  [warn] $1"; }
fail()  { echo "  [FAIL] $1"; exit 1; }

# ── OS Detection ───────────────────────────────────────────────────────────────
detect_os() {
    case "$(uname -s)" in
        Darwin*) OS="macos" ;;
        Linux*)  OS="linux" ;;
        *)       OS="unknown" ;;
    esac
    export OS
}

# ── Symlink helper (idempotent + backup) ───────────────────────────────────────
link_file() {
    local src="$1" dst="$2"

    # Already linked correctly — skip
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        ok "Already linked: $dst"
        return
    fi

    # Real file exists — back it up
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/"
        warn "Backed up: $dst → $BACKUP_DIR/"
    fi

    # Remove stale symlink
    if [ -L "$dst" ]; then
        rm "$dst"
    fi

    ln -sf "$src" "$dst"
    ok "Linked: $dst → $src"
}

# ── Install .symlink files → ~/.<name> ────────────────────────────────────────
install_symlinks() {
    info "Installing symlinks..."

    while IFS= read -r -d '' src; do
        filename="$(basename "$src")"
        dst="$HOME/.${filename%.symlink}"
        link_file "$src" "$dst"
    done < <(find "$DOTFILES_DIR" -name "*.symlink" -not -path "*/.git/*" -print0)
}

# ── Install Starship config → ~/.config/starship.toml ─────────────────────────
install_starship() {
    info "Installing Starship config..."
    mkdir -p "$HOME/.config"
    link_file "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
}

# ── Install Ghostty config → ~/.config/ghostty/ ───────────────────────────────
install_ghostty() {
    info "Installing Ghostty config..."
    mkdir -p "$HOME/.config/ghostty"

    for src in "$DOTFILES_DIR/ghostty/"*; do
        [ -f "$src" ] || continue
        dst="$HOME/.config/ghostty/$(basename "$src")"
        link_file "$src" "$dst"
    done
}

# ── Install Claude Code config → ~/.claude/ ───────────────────────────────────
install_claude() {
    info "Installing Claude Code config..."
    mkdir -p "$HOME/.claude/commands"
    mkdir -p "$HOME/.claude/hooks"

    for src in "$DOTFILES_DIR/claude/"*; do
        [ -f "$src" ] || continue
        dst="$HOME/.claude/$(basename "$src")"
        link_file "$src" "$dst"
    done

    for src in "$DOTFILES_DIR/claude/commands/"*; do
        [ -f "$src" ] || continue
        dst="$HOME/.claude/commands/$(basename "$src")"
        link_file "$src" "$dst"
    done

    for src in "$DOTFILES_DIR/claude/hooks/"*; do
        [ -f "$src" ] || continue
        dst="$HOME/.claude/hooks/$(basename "$src")"
        link_file "$src" "$dst"
        chmod +x "$src"
    done
}

# ── Install cheat docs → ~/.local/share/cheat/ ───────────────────────────────
install_cheat() {
    info "Installing cheat docs..."
    mkdir -p "$HOME/.local/share"
    link_file "$DOTFILES_DIR/docs" "$HOME/.local/share/cheat"
}

# ── Install bin/ scripts → ~/.local/bin/ ──────────────────────────────────────
install_bin() {
    info "Installing bin scripts..."
    mkdir -p "$HOME/.local/bin"

    for src in "$DOTFILES_DIR/bin/"*; do
        [ -f "$src" ] || continue
        dst="$HOME/.local/bin/$(basename "$src")"
        link_file "$src" "$dst"
        chmod +x "$src"
    done
}

# ── Install global git hooks ──────────────────────────────────────────────────
install_git_hooks() {
    info "Installing global git hooks..."
    mkdir -p "$HOME/.git-hooks"

    for src in "$DOTFILES_DIR/git-hooks/"*; do
        [ -f "$src" ] || continue
        dst="$HOME/.git-hooks/$(basename "$src")"
        link_file "$src" "$dst"
        chmod +x "$src"
    done

    git config --global core.hooksPath "$HOME/.git-hooks"
    ok "Set global core.hooksPath to ~/.git-hooks"
}

# ── Ensure ~/.local/bin is in PATH ────────────────────────────────────────────
ensure_path() {
    local shell_rc=""
    case "$OS" in
        macos) shell_rc="$HOME/.zshrc" ;;
        linux) shell_rc="$HOME/.bashrc" ;;
    esac

    if [ -n "$shell_rc" ] && [ -f "$shell_rc" ]; then
        if ! grep -q '.local/bin' "$shell_rc"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_rc"
            ok "Added ~/.local/bin to PATH in $shell_rc"
        else
            ok "~/.local/bin already in PATH"
        fi
    fi
}

# ── Main ───────────────────────────────────────────────────────────────────────
main() {
    echo ""
    echo "Installing devenv from $DOTFILES_DIR"
    echo "────────────────────────────────────────"

    detect_os
    info "Detected OS: $OS"

    install_symlinks
    install_starship
    install_ghostty
    install_claude
    install_cheat
    install_bin
    install_git_hooks
    ensure_path

    echo "────────────────────────────────────────"
    echo "  Done! Restart your terminal to apply changes."
    echo ""
}

main
