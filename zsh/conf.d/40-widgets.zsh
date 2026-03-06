# Fix bracketed paste showing ^[[200~ literally
unset zle_bracketed_paste

# Project picker — ctrl+p to fzf your project dirs and cd there
proj-widget() {
  local dir
  dir=$(find ~/Documents/dev ~/Documents/personal -mindepth 1 -maxdepth 1 -type d | fzf --height 40%)
  [[ -n "$dir" ]] && cd "$dir"
  zle reset-prompt
}
zle -N proj-widget
bindkey '^p' proj-widget
