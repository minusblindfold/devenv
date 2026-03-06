# devenv zsh config loader
# Sources all conf.d modules in sorted order.
for _f in "${0:A:h}/conf.d/"*.zsh; do
  [ -f "$_f" ] && source "$_f"
done
unset _f
