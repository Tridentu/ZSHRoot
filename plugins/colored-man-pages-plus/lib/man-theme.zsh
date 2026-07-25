# man-theme.zsh — list, preview, and set the active man-page color theme.
#
#   man-theme              list themes, marking the active one
#   man-theme list         same as above
#   man-theme preview NAME render a sample page in NAME (defaults to a few)
#   man-theme set NAME     use NAME for this session
#   man-theme set NAME -s  ...and append the export to ~/.zshrc
#   man-theme current      print the active theme name

cmp_themes() {
  local f
  for f in "${CMP_DIR}"/themes/*.zsh; do
    print -r -- ${${f:t}:r}
  done
  print -r -- auto
}

cmp_current_theme() {
  local t
  zstyle -s ':colored-man:theme' name t
  [[ -n $t ]] || t=${COLORED_MAN_THEME:-dracula}
  print -r -- $t
}

# Render the bundled sample man-page text through a given theme to stdout.
cmp_render_sample() {
  local theme=$1
  local saved_depth=$CMP_DEPTH
  CMP_DEPTH=$(cmp_depth)
  cmp_apply_theme "$theme"
  CMP_DEPTH=$saved_depth
  CMP_LINKS=0 CMP_SEPARATORS=1 CMP_WIDTH=${COLUMNS:-80} \
    LC_ALL=C awk -f "${CMP_DIR}/lib/colorize.awk" "${CMP_DIR}/test/fixtures/sample.raw"
}

man-theme() {
  local cmd=${1:-list}
  case $cmd in
    list|"")
      local active=$(cmp_current_theme) t
      print -r -- "Available man-page themes:"
      for t in $(cmp_themes); do
        if [[ $t == $active ]]; then
          print -r -- "  * ${t}  (active)"
        else
          print -r -- "    ${t}"
        fi
      done
      print -r -- ""
      print -r -- "Preview:  man-theme preview <name>"
      print -r -- "Set:      man-theme set <name> [-s|--save]"
      ;;
    current)
      cmp_current_theme
      ;;
    preview)
      local themes=(${@:2})
      (( $#themes )) || themes=(dracula catppuccin gruvbox tokyonight)
      local t
      for t in $themes; do
        print -r -- ""
        print -r -- "──── ${t} ────"
        cmp_render_sample "$t"
      done
      ;;
    set)
      local name=$2
      if [[ -z $name ]]; then
        print -r -- "usage: man-theme set <name> [-s|--save]" >&2
        return 1
      fi
      if ! print -r -- "$(cmp_themes)" | grep -qx "$name"; then
        print -r -- "man-theme: unknown theme '$name'" >&2
        return 1
      fi
      zstyle ':colored-man:theme' name "$name"
      export COLORED_MAN_THEME="$name"
      print -r -- "man-theme: now using '$name' for this session."
      if [[ $3 == -s || $3 == --save ]]; then
        print -r -- "export COLORED_MAN_THEME=$name" >> "${HOME}/.zshrc"
        print -r -- "man-theme: saved to ~/.zshrc"
      fi
      ;;
    *)
      print -r -- "usage: man-theme [list|preview <name>|set <name> [-s]|current]" >&2
      return 1
      ;;
  esac
}
