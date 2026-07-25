# resolve-color.zsh — turn a theme's hex / ANSI-index color specs into the
# correct terminal escape for the active color depth. Authored colors are
# written once in hex; this degrades them to 256 or 16 colors automatically.
#
# Public:
#   cmp_depth                 -> echoes truecolor | 256 | 16
#   cmp_apply_theme <name>    -> loads theme + overrides, exports CMP_<ROLE>

# Role -> SGR attribute prefix (bold / italic / underline).
cmp_role_attr() {
  case $1 in
    header|subheader|flag) print -r -- 1 ;;   # bold
    argument)              print -r -- 3 ;;    # italic
    path)                  print -r -- 4 ;;    # underline
    *)                     print -r -- "" ;;
  esac
}

cmp_depth() {
  if [[ ${COLORTERM:-} == (truecolor|24bit) ]]; then
    print -r -- truecolor
  elif (( ${$(tput colors 2>/dev/null):-0} >= 256 )); then
    print -r -- 256
  else
    print -r -- 16
  fi
}

# "#rrggbb" -> "R G B" (decimal).
cmp_hex_rgb() {
  local h=${1#\#}
  print -r -- $(( 16#${h[1,2]} )) $(( 16#${h[3,4]} )) $(( 16#${h[5,6]} ))
}

# "#rrggbb" -> nearest xterm-256 cube index.
cmp_hex_256() {
  local r g b; read r g b < <(cmp_hex_rgb "$1")
  local ri=$(( (r * 5 + 127) / 255 ))
  local gi=$(( (g * 5 + 127) / 255 ))
  local bi=$(( (b * 5 + 127) / 255 ))
  print -r -- $(( 16 + 36 * ri + 6 * gi + bi ))
}

# "#rrggbb" -> nearest of the 16 base ANSI colors (by RGB distance).
cmp_hex_16() {
  local r g b; read r g b < <(cmp_hex_rgb "$1")
  local -a pal=(
    0 0 0       128 0 0     0 128 0     128 128 0
    0 0 128     128 0 128   0 128 128   192 192 192
    128 128 128 255 0 0     0 255 0     255 255 0
    0 0 255     255 0 255   0 255 255   255 255 255
  )
  local best=7 bestd=-1 i pr pg pb d
  for i in {0..15}; do
    pr=${pal[$((i*3+1))]} pg=${pal[$((i*3+2))]} pb=${pal[$((i*3+3))]}
    d=$(( (r-pr)*(r-pr) + (g-pg)*(g-pg) + (b-pb)*(b-pb) ))
    if (( bestd < 0 || d < bestd )); then bestd=$d; best=$i; fi
  done
  print -r -- $best
}

# Build the SGR escape for one role at the current depth.
#   $1 = role name   $2 = color spec ("#rrggbb" or an integer ANSI index)
cmp_escape() {
  local role=$1 spec=$2 attr code seq
  attr=$(cmp_role_attr "$role")
  if [[ $spec == \#* ]]; then
    case ${CMP_DEPTH:-$(cmp_depth)} in
      truecolor) local r g b; read r g b < <(cmp_hex_rgb "$spec"); code="38;2;$r;$g;$b" ;;
      256)       code="38;5;$(cmp_hex_256 "$spec")" ;;
      *)         code="38;5;$(cmp_hex_16 "$spec")" ;;
    esac
  else
    code="38;5;$spec"   # ANSI index 0-15
  fi
  seq="${attr:+$attr;}$code"
  printf '\033[%sm' "$seq"
}

# Load a built-in theme into the global cmp_palette assoc array.
cmp_load_theme() {
  local name=$1 f="${CMP_DIR}/themes/${name}.zsh"
  [[ -r $f ]] || return 1
  source "$f"
}

# Resolve <theme> (+ per-role overrides) into exported CMP_<ROLE> escapes.
cmp_apply_theme() {
  local name=$1 role spec
  typeset -gA cmp_palette
  cmp_palette=()
  cmp_load_theme "$name" || { cmp_load_theme dracula || return 1 }

  # Per-role user overrides win.
  if (( ${+COLORED_MAN_OVERRIDE} )); then
    for role in ${(k)COLORED_MAN_OVERRIDE}; do
      cmp_palette[$role]=${COLORED_MAN_OVERRIDE[$role]}
    done
  fi

  : ${CMP_DEPTH:=$(cmp_depth)}
  for role in header subheader command flag argument path literal punct default; do
    spec=${cmp_palette[$role]}
    if [[ -n $spec ]]; then
      export CMP_${(U)role}="$(cmp_escape "$role" "$spec")"
    else
      export CMP_${(U)role}=""
    fi
  done
}
