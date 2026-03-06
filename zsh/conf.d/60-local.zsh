# Load local config (work-specific, secrets — not tracked in devenv)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# Lazy-load nvm — initialises on first call to nvm/node/npm/npx
if [ -n "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
  _nvm_load() {
    unset -f nvm node npm npx
    source "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
  }
  nvm()  { _nvm_load && nvm "$@"; }
  node() { _nvm_load && node "$@"; }
  npm()  { _nvm_load && npm "$@"; }
  npx()  { _nvm_load && npx "$@"; }
fi
