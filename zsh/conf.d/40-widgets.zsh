# Fix bracketed paste showing ^[[200~ literally
unset zle_bracketed_paste

# Project picker — ctrl+p to fzf your project dirs and cd there
# Reads paths from ~/.config/devenv/paths (one per line, ~ expanded)
proj-widget() {
  local paths_file="${XDG_CONFIG_HOME:-$HOME/.config}/devenv/paths"
  [[ -f "$paths_file" ]] || return

  local dir dirs=()
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    local expanded="${line/#\~/$HOME}"
    [[ -d "$expanded" ]] || continue
    dirs+=("$expanded")
  done < "$paths_file"

  (( ${#dirs[@]} )) || return

  # Include root dirs themselves + their immediate children
  dir=$( { printf '%s\n' "${dirs[@]}"; find "${dirs[@]}" -mindepth 1 -maxdepth 1 -type d; } | sort -u | fzf --height 40%)
  [[ -n "$dir" ]] && cd "$dir"
  zle reset-prompt
}
zle -N proj-widget
bindkey '^p' proj-widget
