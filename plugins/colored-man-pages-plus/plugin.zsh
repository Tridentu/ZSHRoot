# colored-man-pages-plus — semantic, themeable man-page colorizer for zsh.
#
# A drop-in upgrade to oh-my-zsh's colored-man-pages: instead of tinting by
# text attribute (bold/underline only), it colors by *meaning* — section
# headers, commands, flags, arguments, paths, literals — with curated themes,
# OSC-8 links, auto light/dark detection, and a `man-theme` switcher.
#
# Config (all optional):
#   zstyle ':colored-man:theme' name dracula     # or: export COLORED_MAN_THEME=dracula
#   COLORED_MAN_DARK_THEME=gruvbox                # dark theme picked by `auto`
#   typeset -A COLORED_MAN_OVERRIDE; COLORED_MAN_OVERRIDE[flag]="#ff5555"
#   COLORED_MAN_SEPARATORS=off                    # default on
#   COLORED_MAN_LINKS=off                         # default on

# Resolve this file's directory (Zsh Plugin Standard).
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"
typeset -g CMP_DIR="${0:A:h}"

source "${CMP_DIR}/lib/resolve-color.zsh"
source "${CMP_DIR}/lib/detect-bg.zsh"
source "${CMP_DIR}/lib/man-theme.zsh"

# Pick the theme name, expanding `auto` via background detection.
cmp_resolve_theme_name() {
  local t
  zstyle -s ':colored-man:theme' name t
  [[ -n $t ]] || t=${COLORED_MAN_THEME:-dracula}
  if [[ $t == auto ]]; then
    if cmp_bg_is_light; then t=light; else t=${COLORED_MAN_DARK_THEME:-dracula}; fi
  fi
  print -r -- $t
}

cmp_flag() { [[ ${(P)1:-on} == off ]] && print -r -- 0 || print -r -- 1 }

# The wrapper: configure the environment, then call the real pager-driven tool.
function man dman debman {
  typeset -g CMP_DEPTH
  CMP_DEPTH=$(cmp_depth)
  cmp_apply_theme "$(cmp_resolve_theme_name)"

  local width=${MANWIDTH:-${COLUMNS:-80}}
  (( width > 0 )) || width=80

  export CMP_WIDTH=$width
  export CMP_LINKS=$(cmp_flag COLORED_MAN_LINKS)
  export CMP_SEPARATORS=$(cmp_flag COLORED_MAN_SEPARATORS)
  export CMP_AWK="${CMP_DIR}/lib/colorize.awk"
  export GROFF_NO_SGR=1                      # force overstrike on groff systems

  # Respect a user's custom MANPAGER unless they opt into ours via FORCE.
  if [[ -z ${MANPAGER:-} || -n ${COLORED_MAN_FORCE:-} || ${MANPAGER} == *"/lib/shim.sh" ]]; then
    export MANPAGER="${CMP_DIR}/lib/shim.sh"
  fi

  command $0 "$@"
}
