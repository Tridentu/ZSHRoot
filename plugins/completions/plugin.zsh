export CARAPACE_BRIDGES='zsh,bash,inshellisense'
zstyle ':completion:*' format $'\e[2;37mCompleting entry "%d"\e[m'
source <(carapace _carapace)
