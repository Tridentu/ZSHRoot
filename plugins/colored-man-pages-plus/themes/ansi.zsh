# ansi — map roles onto the terminal's own 16 ANSI colors, so man pages match
# whatever color scheme the terminal already uses. Values are ANSI indices
# (0-15); the resolver renders them with the 16-color palette in use.
cmp_palette=(
  header    4    # blue
  subheader 4    # blue
  command   6    # cyan
  flag      5    # magenta
  argument  3    # yellow
  path      2    # green
  literal   11   # bright yellow
  punct     8    # bright black (grey)
  default   ""
)
