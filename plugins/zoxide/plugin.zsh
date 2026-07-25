# ==============================================================================
# 1. PYTHON VIRTUAL ENVIRONMENT AUTO-ACTIVATOR
# ==============================================================================
function _auto_activate_venv() {
  # Prevent running if we are inside root filesystems
  [[ "$PWD" == "/" || "$PWD" == "/root" ]] && return

  # Look for a .venv folder in the current directory OR any parent directory
  local current_dir="$PWD"
  while [[ "$current_dir" != "/" ]]; do
    if [[ -d "$current_dir/.venv" && -f "$current_dir/.venv/bin/activate" ]]; then
      if [[ "$VIRTUAL_ENV" != "$current_dir/.venv" ]]; then
        [[ -n "$VIRTUAL_ENV" ]] && deactivate 2>/dev/null
        source "$current_dir/.venv/bin/activate"
      fi
      return
    elif [[ -d "$current_dir/venv" && -f "$current_dir/venv/bin/activate" ]]; then
      if [[ "$VIRTUAL_ENV" != "$current_dir/venv" ]]; then
        [[ -n "$VIRTUAL_ENV" ]] && deactivate 2>/dev/null
        source "$current_dir/venv/bin/activate"
      fi
      return
    fi
    current_dir="${current_dir%/*}"
    [[ -z "$current_dir" ]] && current_dir="/"
  done

  # If no venv was found anywhere in the tree, deactivate the current one safely
  if [[ -n "$VIRTUAL_ENV" ]]; then
    deactivate
  fi
}

# ==============================================================================
# 3. DYNAMIC GEM PATH LOOKUP (Runs after chruby picks a Ruby version)
# ==============================================================================
function _update_gem_bin_path() {
  if [[ -n "$OLD_GEM_HOME" ]]; then
    PATH="${PATH//:$OLD_GEM_HOME\/bin/}"
  fi
  if [[ -n "$GEM_HOME" ]]; then
    export PATH="$GEM_HOME/bin:$PATH"
    export OLD_GEM_HOME="$GEM_HOME"
  fi
}

autoload -U add-zsh-hook



add-zsh-hook chpwd _auto_activate_venv



add-zsh-hook chpwd _update_gem_bin_path



# ==============================================================================
# 2. ZOXIDE NAVIGATION CONFIGURATION
# ==============================================================================
if (( $+commands[zoxide] )); then
  eval "$(zoxide init --cmd ${ZOXIDE_CMD_OVERRIDE:-z} zsh)"
  alias cd="z"
else
  echo '[zshroot] zoxide not found, please install it from https://github.com/ajeetdsouza/zoxide'
fi

# Run once on startup in case the terminal drops straight into a project directory
_auto_activate_venv
_update_gem_bin_path
