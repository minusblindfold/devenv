eval "$(starship init zsh)"

# Set terminal title to current directory
precmd() { print -Pn "\e]2;%~\a" }
