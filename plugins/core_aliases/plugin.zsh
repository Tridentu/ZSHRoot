# Common Aliases

function run_wttr(){
  echo  "$(curl wttr.in/$1)"
}

alias iflat="sudo flatpak install "
alias editfile="$ZSH_EDITOR "
alias wttr=run_wttr
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -"
alias zscreen="zellij -l welcome"
