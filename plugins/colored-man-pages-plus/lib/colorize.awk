#!/usr/bin/awk -f
# colorize.awk — semantic man-page colorizer.
#
# Reads groff/mandoc-formatted man text (with backspace overstrike) on stdin
# and emits ANSI-colored text. Role colors and feature flags arrive via the
# environment (see lib/shim.sh), so this script knows nothing about color
# depth or theming — it only maps *meaning* to the escapes it is handed.
#
# Overstrike grammar produced by groff/mandoc for a terminal pager:
#   bold      char  BS  char            ( g \b g )
#   underline '_'   BS  char            ( _ \b n )   <- man renders args italic
# Anything else passes through untouched. Unmatched text is never altered,
# so the worst case is "uncolored", never "mangled".

BEGIN {
  ESC   = sprintf("%c", 27)
  BS    = sprintf("%c", 8)
  RESET = ESC "[0m"

  C["header"]    = ENVIRON["CMP_HEADER"]
  C["subheader"] = ENVIRON["CMP_SUBHEADER"]
  C["command"]   = ENVIRON["CMP_COMMAND"]
  C["flag"]      = ENVIRON["CMP_FLAG"]
  C["argument"]  = ENVIRON["CMP_ARGUMENT"]
  C["path"]      = ENVIRON["CMP_PATH"]
  C["literal"]   = ENVIRON["CMP_LITERAL"]
  C["punct"]     = ENVIRON["CMP_PUNCT"]
  C["default"]   = ENVIRON["CMP_DEFAULT"]

  LINK  = (ENVIRON["CMP_LINKS"]      == "1")
  SEP   = (ENVIRON["CMP_SEPARATORS"] == "1")
  WIDTH = ENVIRON["CMP_WIDTH"] + 0
  if (WIDTH <= 0) WIDTH = 80

  RULE = (C["punct"] != "" ? C["punct"] : C["default"])
  firstheader = 1
  SECTION = ""
}

# ---- overstrike decoder -----------------------------------------------------
# Fills globals vis[1..N] (visible char) and att[1..N] (0=plain,1=bold,2=under).
function decode(s,   i, L, ch, nx, ov) {
  N = 0; L = length(s); i = 1
  while (i <= L) {
    ch = substr(s, i, 1)
    nx = substr(s, i + 1, 1)
    if (nx == BS) {
      ov = substr(s, i + 2, 1)
      if (ch == "_" && ov != "_")      { N++; vis[N] = ov; att[N] = 2 }
      else if (ov == "_" && ch != "_") { N++; vis[N] = ch; att[N] = 2 }
      else                             { N++; vis[N] = ov; att[N] = 1 }
      i += 3
      # collapse heavier overstrike chains: x BS x BS x
      while (substr(s, i, 1) == BS) {
        ov = substr(s, i + 1, 1)
        if (ov != "_") vis[N] = ov
        if (att[N] != 2) att[N] = 1
        i += 2
      }
    } else {
      N++; vis[N] = ch; att[N] = 0; i++
    }
  }
}

# ---- helpers ----------------------------------------------------------------
function wrap(text, color) {
  if (color == "" || text == "") return text
  return color text RESET
}

function osc8(uri, shown) {
  return ESC "]8;;" uri ESC "\\" shown ESC "]8;;" ESC "\\"
}

function trim(s) {
  gsub(/^[ \t]+|[ \t]+$/, "", s)
  return s
}

function rule(   r, i) {
  r = ""
  for (i = 0; i < WIDTH; i++) r = r "\xe2\x94\x80"   # U+2500 light horizontal
  return (RULE != "" ? RULE r RESET : r)
}

# A bold run is one token: a flag if it opens with a dash, else a command name.
function boldtoken(run) {
  if (run ~ /^--?[A-Za-z0-9]/) return wrap(run, C["flag"])
  return wrap(run, C["command"])
}

# Wrap a name(section) cross-reference, linking it when links are enabled.
function xref(tok) {
  if (LINK) return osc8("man:" tok, wrap(tok, C["command"]))
  return wrap(tok, C["command"])
}

function urlref(tok) {
  if (LINK) return osc8(tok, wrap(tok, C["literal"]))
  return wrap(tok, C["literal"])
}

# Colorize a run of plain (non-attributed) text: links, literals, paths, and
# (inside SYNOPSIS) punctuation. Everything else accrues in the default color.
function plainseg(s,   res, i, L, rest, tok, defbuf, c) {
  res = ""; defbuf = ""; L = length(s); i = 1
  while (i <= L) {
    rest = substr(s, i)
    if (match(rest, /^[A-Za-z_][A-Za-z0-9_.+-]*\([0-9][A-Za-z]?\)/)) {
      tok = substr(rest, 1, RLENGTH)
      res = res wrap(defbuf, C["default"]) xref(tok); defbuf = ""; i += RLENGTH; continue
    }
    if (match(rest, /^https?:\/\/[^ \t)]+/)) {
      tok = substr(rest, 1, RLENGTH)
      res = res wrap(defbuf, C["default"]) urlref(tok); defbuf = ""; i += RLENGTH; continue
    }
    if (match(rest, /^'[^']*'/) || match(rest, /^"[^"]*"/)) {
      tok = substr(rest, 1, RLENGTH)
      res = res wrap(defbuf, C["default"]) wrap(tok, C["literal"]); defbuf = ""; i += RLENGTH; continue
    }
    if (match(rest, /^~?(\/[A-Za-z0-9._+-]+)+\/?/)) {
      tok = substr(rest, 1, RLENGTH)
      # require it to look path-like (has a slash) and not be a lone "/"
      if (tok ~ /\/[A-Za-z0-9._+-]/) {
        res = res wrap(defbuf, C["default"]) wrap(tok, C["path"]); defbuf = ""; i += RLENGTH; continue
      }
    }
    if (SECTION == "SYNOPSIS" && match(rest, /^[][|]+/)) {
      tok = substr(rest, 1, RLENGTH)
      res = res wrap(defbuf, C["default"]) wrap(tok, C["punct"]); defbuf = ""; i += RLENGTH; continue
    }
    c = substr(s, i, 1); defbuf = defbuf c; i++
  }
  return res wrap(defbuf, C["default"])
}

# ---- main -------------------------------------------------------------------
{
  decode($0)

  plain = ""
  for (i = 1; i <= N; i++) plain = plain vis[i]

  lead = 0
  while (lead < N && vis[lead + 1] == " ") lead++

  anybold = 0
  for (i = 1; i <= N; i++) if (att[i] == 1) { anybold = 1; break }

  tr = trim(plain)

  # Top-level section header: column 0, bold, all-caps words.
  if (lead == 0 && N > 0 && anybold && tr ~ /^[A-Z][A-Z0-9]+([ ][A-Z0-9]+)*$/) {
    if (SEP && !firstheader) print rule()
    firstheader = 0
    SECTION = tr
    print wrap(plain, C["header"])
    next
  }

  # Indented sub-section header: bold, all-caps, indented.
  if (lead > 0 && N > 0 && anybold && tr ~ /^[A-Z][A-Za-z0-9]+([ ][A-Za-z0-9]+)*$/) {
    allbold = 1
    for (i = lead + 1; i <= N; i++) if (vis[i] != " " && att[i] != 1) { allbold = 0; break }
    if (allbold) { print wrap(plain, C["subheader"]); next }
  }

  # Body line: emit run by run.
  out = ""; i = 1
  while (i <= N) {
    a = att[i]; j = i; run = ""
    while (j <= N && att[j] == a) { run = run vis[j]; j++ }
    if      (a == 2) out = out wrap(run, C["argument"])
    else if (a == 1) out = out boldtoken(run)
    else             out = out plainseg(run)
    i = j
  }
  print out
}
