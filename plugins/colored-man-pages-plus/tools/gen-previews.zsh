#!/usr/bin/env zsh
# Generate SVG theme previews for the README, straight from the theme palettes
# so the images can never drift from the real colors.
#   zsh tools/gen-previews.zsh
emulate -L zsh
set -u
typeset -g CMP_DIR=${0:A:h:h}
mkdir -p "${CMP_DIR}/docs/img"

# Background / default-foreground per theme (used only for the preview canvas).
typeset -A BG=(
  dracula "#282a36"  catppuccin "#1e1e2e"  gruvbox "#282828"
  tokyonight "#1a1b26"  light "#fafafa"  ansi "#1d1f21"
)
typeset -A FG=(
  dracula "#f8f8f2"  catppuccin "#cdd6f4"  gruvbox "#ebdbb2"
  tokyonight "#c0caf5"  light "#383a42"  ansi "#c5c8c6"
)
# Representative hex for the 16 ANSI slots, for rendering the `ansi` theme.
typeset -a ANSIHEX=(
  "#1d1f21" "#cc6666" "#b5bd68" "#f0c674" "#81a2be" "#b294bb" "#8abeb7" "#c5c8c6"
  "#666666" "#d54e53" "#b9ca4a" "#e7c547" "#7aa6da" "#c397d8" "#70c0b1" "#eaeaea"
)

to_hex() {  # color spec (#hex or ANSI index) + theme -> #hex
  local spec=$1 fg=$2
  if   [[ -z $spec ]];        then print -r -- "$fg"
  elif [[ $spec == \#* ]];    then print -r -- "$spec"
  else                             print -r -- "${ANSIHEX[$((spec+1))]}"
  fi
}

xml_escape() { local s=$1; s=${s//&/\&amp;}; s=${s//</\&lt;}; s=${s//>/\&gt;}; print -r -- "$s"; }

# ---- the sample page, as (role, text) segment pairs per line ----------------
# Roles: header command flag argument path literal punct default
typeset -ga DOC
DOC=(
  "header:SYNOPSIS"
  "default:     |command:grep|default: |punct:[|flag:-i|punct:]|default: |punct:[|flag:--color|punct:[=|argument:WHEN|punct:]]|default: |argument:PATTERNS|default: |punct:[|argument:FILE|default:...|punct:]"
  ""
  "header:DESCRIPTION"
  "default:     |flag:-i|default:, |flag:--ignore-case|default:        ignore case distinctions"
  "default:     |flag:-r|default:, |flag:--recursive|default:         search directories recursively"
  ""
  "default:     |command:grep|default: |flag:-r|default: |literal:'TODO'|default: |path:~/src|default: |path:/var/log"
  ""
  "header:SEE ALSO"
  "default:     |command:egrep(1)|default:, |command:fgrep(1)|default:, |command:re_format(7)"
)

gen_theme() {
  local theme=$1
  local out="${CMP_DIR}/docs/img/${theme}.svg"
  typeset -gA cmp_palette; cmp_palette=()
  source "${CMP_DIR}/themes/${theme}.zsh"
  local bg=${BG[$theme]} fg=${FG[$theme]}
  local -A col
  local role
  for role in header subheader command flag argument path literal punct; do
    col[$role]=$(to_hex "${cmp_palette[$role]}" "$fg")
  done
  col[default]=$fg

  local -A style=(
    header "font-weight=\"bold\"" subheader "font-weight=\"bold\"" flag "font-weight=\"bold\""
    argument "font-style=\"italic\"" path "text-decoration=\"underline\""
    command "" literal "" punct "" default ""
  )

  local cw=8.4 lh=22 padx=22 pady=20 fs=14
  local nlines=$(( ${#DOC} + 2 ))
  local height=$(( pady*2 + nlines*lh + 14 ))
  local width=720

  {
    print -r -- "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"$width\" height=\"$height\" font-family=\"ui-monospace,SFMono-Regular,Menlo,Consolas,monospace\" font-size=\"$fs\">"
    print -r -- "  <rect width=\"$width\" height=\"$height\" rx=\"10\" fill=\"$bg\"/>"
    # window chrome
    print -r -- "  <circle cx=\"20\" cy=\"18\" r=\"5\" fill=\"#ff5f56\"/><circle cx=\"38\" cy=\"18\" r=\"5\" fill=\"#ffbd2e\"/><circle cx=\"56\" cy=\"18\" r=\"5\" fill=\"#27c93f\"/>"
    print -r -- "  <text x=\"$((width/2))\" y=\"22\" fill=\"$fg\" opacity=\"0.55\" text-anchor=\"middle\">man grep — ${theme}</text>"

    local y=$(( pady + 34 )) role text seg tspans line
    for line in "${DOC[@]}"; do
      if [[ -z $line ]]; then y=$(( y + lh )); continue; fi
      tspans=""
      local -a segs=("${(@s:|:)line}")
      for seg in "${segs[@]}"; do
        role=${seg%%:*}; text=${seg#*:}
        local c=${col[$role]} st=${style[$role]}
        tspans+="<tspan ${st:+$st }fill=\"$c\">$(xml_escape "$text")</tspan>"
      done
      print -r -- "  <text x=\"$padx\" y=\"$y\" xml:space=\"preserve\">$tspans</text>"
      y=$(( y + lh ))
    done
    print -r -- "</svg>"
  } > "$out"
  print -r -- "wrote $out"
}

for t in dracula catppuccin gruvbox tokyonight light ansi; do
  gen_theme "$t"
done
