# 4. Interactive log-search utility function
function log-search() {
    journalctl -n 2000 --no-pager | fzf \
        --header='[System Logs] Type to filter | Press Enter to exit' \
        --tac \
        --no-sort \
        --layout=reverse \
        --preview='echo {} | fold -s -w $(($FZF_PREVIEW_COLUMNS - 2))' \
        --preview-window="up:40%:wrap"
}

alias log-search='log-search'
