# Delete up to previous `/` with ctrl-w
export WORDCHARS=${WORDCHARS/\/}

autoload -U select-word-style
select-word-style bash

# Mac Keyboard patches
SHIFT_TAB="^[[Z"
ALT_LEFT="^[[1;9D"
ALT_RIGHT="^[[1;9C"
UP_ARROW="^[[A"
DOWN_ARROW="^[[B"
DELETE="^[[3~"

# Move back and forward words
bindkey $ALT_LEFT   backward-word
bindkey $ALT_RIGHT  forward-word
# Shift Tab to go back in autocomplete
bindkey $SHIFT_TAB  reverse-menu-complete
# Move through history based upon was already in the prompt
bindkey $UP_ARROW   history-beginning-search-backward
bindkey $DOWN_ARROW history-beginning-search-forward
# Fix delete key
bindkey $DELETE delete-char
