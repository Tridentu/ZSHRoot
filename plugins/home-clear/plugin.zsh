function __zsh-allclear__on-chpwd() {
  if [[ $PWD = $HOME ]]; then
    emulate -L zsh; clear;
  fi
}
autoload -U add-zsh-hook

add-zsh-hook chpwd __zsh-allclear__on-chpwd
