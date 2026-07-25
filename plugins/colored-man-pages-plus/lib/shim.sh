#!/bin/sh
# shim.sh — the MANPAGER. Reads groff/mandoc-formatted man text on stdin,
# runs it through the colorizer, and pages it. Color escapes and feature
# flags are supplied in the environment by the plugin (CMP_* variables).
#
# Fail-safe: with NO_COLOR set, no colorizer available, or output not going
# to a terminal, it pages the text untouched.

awk_script="${CMP_AWK}"

# Choose a pager: prefer less -R (handles SGR color + OSC-8 links).
if [ -n "${CMP_PAGER}" ]; then
  pager="${CMP_PAGER}"
elif command -v less >/dev/null 2>&1; then
  pager="less -R"
else
  pager="${PAGER:-more}"
fi

# Passthrough when we must not (or cannot) colorize.
if [ -n "${NO_COLOR}" ] || [ ! -t 1 ] || [ -z "${awk_script}" ] || \
   ! command -v awk >/dev/null 2>&1; then
  exec sh -c "$pager"
fi

# Byte-mode (LC_ALL=C) so the overstrike parser is deterministic and never
# trips on multibyte sequences.
LC_ALL=C awk -f "$awk_script" | sh -c "$pager"
