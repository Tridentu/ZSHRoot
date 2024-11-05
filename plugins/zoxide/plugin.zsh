if (( $+commands[zoxide] )); then
  eval "$(zoxide init --cmd ${ZOXIDE_CMD_OVERRIDE:-z} zsh)"
  alias cd="z"
else
  echo '[zshroot] zoxide not found, please install it from https://github.com/ajeetdsouza/zoxide'
fi
