# Common Aliases

function run_wttr(){
  echo  "$(curl wttr.in/$1)"
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
