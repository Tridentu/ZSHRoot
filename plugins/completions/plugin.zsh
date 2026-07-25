#!/bin/zsh
export CARAPACE_BRIDGES='zsh,bash'
zstyle ':completion:*' format $'\e[2;37mCompleting entry "%d"\e[m'
source <(carapace _carapace)

0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"
source "${0:A:h}/fzf-tab.zsh"

# 5. INSHELLISENSE PIXEL-PERFECT UI REPLICATION LAYOUT
# --height=10        : Caps the floating menu size to match an IDE dropdown
# --layout=reverse   : Forces the selection block downward from your current text line
# --border=rounded   : Draws the exact graphical box container outline
# --prompt=""        : Strips fzf search labels to mimic a clean popup window
zstyle ':fzf-tab:*' fzf-flags \
  --height=10 \
  --layout=reverse \
  --border=rounded \
  --prompt=" " \
  --color="bg+:-1,header:bold:italic,border:4" \
  --info=hidden \
  --no-bold

# 6. Critical Accuracy Fix: Stop fzf-tab from altering Carapace's path slashes
zstyle ':fzf-tab:*' query-string ''

