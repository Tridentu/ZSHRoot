#!/usr/bin/env zsh
# Test harness for colored-man-pages-plus. Plain zsh + diff, no external deps.
#   zsh test/run.zsh
emulate -L zsh
set -u

typeset -g CMP_DIR=${0:A:h:h}
typeset -gi PASS=0 FAIL=0

ok()   { print -r -- "  ok   - $1"; (( PASS++ )); return 0 }
bad()  { print -r -- "  FAIL - $1"; (( FAIL++ )); return 0 }
check(){
  if [[ $1 == $2 ]]; then
    ok "$3"
  else
    bad "$3"; print -r -- "       expected: $2"; print -r -- "       actual:   $1"
  fi
}

source "${CMP_DIR}/lib/resolve-color.zsh"

ESC=$'\033'
# Truecolor escapes for the engine tests.
typeset -gx CMP_HEADER="${ESC}[1;38;2;189;147;249m" \
            CMP_SUBHEADER="${ESC}[1;38;2;189;147;249m" \
            CMP_COMMAND="${ESC}[38;2;139;233;253m" \
            CMP_FLAG="${ESC}[1;38;2;255;121;198m" \
            CMP_ARGUMENT="${ESC}[3;38;2;255;184;108m" \
            CMP_PATH="${ESC}[4;38;2;80;250;123m" \
            CMP_LITERAL="${ESC}[38;2;241;250;140m" \
            CMP_PUNCT="${ESC}[38;2;98;114;164m" \
            CMP_DEFAULT="" CMP_LINKS=1 CMP_SEPARATORS=1 CMP_WIDTH=80

run_engine() { LC_ALL=C awk -f "${CMP_DIR}/lib/colorize.awk" "$1" }

print -r -- "== engine =="
out=$(run_engine "${CMP_DIR}/test/fixtures/grep.raw")
check $? 0 "engine exits cleanly on grep"

bs=$'\010'
nbs=$(print -r -- "$out" | LC_ALL=C grep -c "$bs")
check $nbs 0 "no backspace/overstrike bytes survive in output"

[[ $out == *"${CMP_HEADER}NAME${ESC}[0m"* ]] && ok "NAME rendered as a header" || bad "NAME header"
[[ $out == *"${CMP_FLAG}--ignore-case${ESC}[0m"* ]] && ok "--ignore-case rendered as a flag" || bad "flag coloring"
[[ $out == *"${CMP_ARGUMENT}pattern${ESC}[0m"* ]] && ok "italic 'pattern' rendered as an argument" || bad "argument coloring"
[[ $out == *"– file pattern searcher"* ]] && ok "UTF-8 en-dash preserved" || bad "en-dash preserved"

# OSC-8 link around a cross-reference.
osc=$'\033]8;;'
[[ $out == *"${osc}man:"* ]] && ok "OSC-8 link emitted for a cross-reference" || bad "OSC-8 link"

# Section separator rules (U+2500) appear with separators on, vanish with off.
rules_on=$(print -r -- "$out" | LC_ALL=C grep -c $'\xe2\x94\x80')
rules_off=$(CMP_SEPARATORS=0 run_engine "${CMP_DIR}/test/fixtures/grep.raw" | LC_ALL=C grep -c $'\xe2\x94\x80')
(( rules_on >= 1 )) && ok "separator rules emitted when on" || bad "separators on ($rules_on)"
check $rules_off 0 "no separator rules when off"

# Every other fixture must parse without error.
for fx in grep ls ssh sample; do
  run_engine "${CMP_DIR}/test/fixtures/${fx}.raw" >/dev/null 2>&1
  check $? 0 "engine exits cleanly on ${fx}"
done

print -r -- "== shim passthrough =="
# NO_COLOR must yield the input bytes unchanged.
in="${CMP_DIR}/test/fixtures/grep.raw"
pt=$(NO_COLOR=1 CMP_PAGER=cat CMP_AWK="${CMP_DIR}/lib/colorize.awk" \
       sh "${CMP_DIR}/lib/shim.sh" < "$in")
orig=$(cat "$in")
check "$pt" "$orig" "NO_COLOR passes man text through unchanged"

print -r -- "== resolver =="
COLORTERM=truecolor check "$(COLORTERM=truecolor cmp_depth)" truecolor "depth = truecolor when COLORTERM=truecolor"
check "$(cmp_hex_256 '#000000')" 16  "hex #000000 -> 256 index 16"
check "$(cmp_hex_256 '#ffffff')" 231 "hex #ffffff -> 256 index 231"

CMP_DEPTH=truecolor
check "$(cmp_escape header '#bd93f9')" "${ESC}[1;38;2;189;147;249m" "header escape (truecolor, bold)"
check "$(cmp_escape argument '#ffb86c')" "${ESC}[3;38;2;255;184;108m" "argument escape (truecolor, italic)"
check "$(cmp_escape flag 5)" "${ESC}[1;38;5;5m" "ansi-index flag escape (bold, 256)"
CMP_DEPTH=256
check "$(cmp_escape command '#8be9fd')" "${ESC}[38;5;$(cmp_hex_256 '#8be9fd')m" "command escape downgrades to 256"

print -r -- "== theme application =="
CMP_DEPTH=truecolor
cmp_apply_theme dracula
check "$CMP_FLAG" "${ESC}[1;38;2;255;121;198m" "dracula flag exported as pink"
typeset -A COLORED_MAN_OVERRIDE=( flag '#ff0000' )
cmp_apply_theme dracula
check "$CMP_FLAG" "${ESC}[1;38;2;255;0;0m" "per-role override beats theme"
unset COLORED_MAN_OVERRIDE

print -r -- ""
print -r -- "== ${PASS} passed, ${FAIL} failed =="
(( FAIL == 0 ))
