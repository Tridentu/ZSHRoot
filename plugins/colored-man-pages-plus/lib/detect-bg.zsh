# detect-bg.zsh — query the terminal background color (OSC 11) and decide
# whether it is light or dark, for the `auto` theme mode.
#
#   cmp_bg_is_light  -> returns 0 (true) on a light background, 1 otherwise
#
# Safe by construction: only queries an interactive TTY, uses a short read
# timeout, caches the verdict per shell, and falls back to "dark" on any
# timeout / parse failure so it can never hang or corrupt the terminal.

cmp_bg_is_light() {
  if [[ -n ${CMP_BG_CACHE:-} ]]; then
    [[ $CMP_BG_CACHE == light ]]
    return
  fi

  local verdict=dark resp r g b lum

  if [[ -t 0 && -t 2 && -z ${NO_COLOR:-} ]]; then
    # Ask the terminal for its background; read the reply from the tty.
    printf '\e]11;?\e\\' > /dev/tty
    IFS= read -r -t 0.15 -k 64 resp < /dev/tty 2>/dev/null

    # Expected reply: ESC ] 11 ; rgb:RRRR/GGGG/BBBB (ST | BEL)
    if [[ $resp == *rgb:* ]]; then
      local hex=${resp#*rgb:}
      r=0x${hex[1,2]} g=0x${hex[6,7]} b=0x${hex[11,12]}
      # Perceptual luminance (0-255); >128 => light.
      lum=$(( (2126 * r + 7152 * g + 722 * b) / 10000 ))
      (( lum > 128 )) && verdict=light
    fi
  fi

  typeset -g CMP_BG_CACHE=$verdict
  [[ $verdict == light ]]
}
