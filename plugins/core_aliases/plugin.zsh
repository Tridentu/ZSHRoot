# Common Aliases

function run_wttr(){
  echo  "$(curl wttr.in/$1)"
}

function load-aliases() {
  if [ -n "$TMUX" ]; then
      eval "$(am init zsh)"
  fi
}

alias iflat="sudo flatpak install "
alias editfile="$ZSH_EDITOR "
alias wttr=run_wttr
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -"
alias zscreen="zellij -l welcome"
alias net-wifi='nmtui connect'
alias net-edit='nmtui edit'
alias net-status='nmcli device status'

alias img='viu -t'

alias rm="rm -i"
alias cp="cp -i --preserve=all"
alias rsync='rsync --perms --xattrs --acls --times --atimes'
alias mv="mv -i"

alias edit-aliases="alman tui"
alias projects="try-rs"
alias reload-env="source ~/.zshrc"
alias cheatsheet="navi"

# Clear out cache and sync up with the Ishimura distribution trees
alias ishimura-sync="apt-get update"
# List out packages explicitly deployed through your custom components
alias ishimura-list="dpkg-query -l | grep -E 'core-kernel|core-userspace'"
# Instantly review broken dependencies across your active toolchains
alias ishimura-verify="apt-get check"
# Force-repair dependency breaks and half-installed packages natively
alias ishimura-repair="apt-get install -f"
# Clean out old package cache and orphan configuration residues
alias ishimura-purge="apt-get autoremove --purge"
# Discover exactly which package owns a specific broken file on your drive
# Example usage: ishimura-who-owns /usr/bin/bash
alias tree='eza --tree --color=always --icons=always --git-ignore'

ishimura-who-owns() {
    dpkg -S "$1"
}

alias \$=''

eval "$(alman init zsh)"


