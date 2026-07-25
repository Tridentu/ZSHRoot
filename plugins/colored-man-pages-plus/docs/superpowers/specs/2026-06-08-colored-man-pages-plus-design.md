# colored-man-pages-plus — Design

**Date:** 2026-06-08
**Status:** Approved design, pre-implementation

## Summary

An Oh My Zsh plugin that colorizes `man` pages with **semantic** highlighting and
real **theming**, as a drop-in upgrade to the stock `colored-man-pages` plugin.

The stock plugin can only tint by *text attribute* — `less`'s termcap exposes
just bold, underline, and standout, so every bold token gets one color and every
underlined token another. This plugin instead assigns colors by **meaning**
(section header, command, flag, argument, path, literal, punctuation), which is
what makes curated themes and per-role overrides worthwhile.

## Decisions (locked during brainstorming)

- **Dependency posture:** pure-zsh + `awk` engine as the always-works default;
  auto-detect optional tools / truecolor to enhance when available.
- **Rendering engine:** Approach A — *recolor groff's own structure*. The filter
  runs after groff has formatted the page, reuses groff's bold/underline/italic
  classification as hints, and layers regex for finer roles. (Rejected: B = hand
  off to `bat`, loses custom roles/links/separators and adds a hard dep; C =
  blind regex, throws away groff's correct attribute info and is fragile.)
- **Theming model:** curated named themes + per-role overrides.
- **Built-in themes:** Dracula, Catppuccin Mocha, Gruvbox, Tokyo Night, a
  `light` variant, and `ansi` (maps roles onto the terminal's own 16 ANSI
  colors, so it inherits whatever scheme the user already runs — zero config).
- **`auto` mode** (distinct from a theme): query the terminal background and
  select the `light` theme on a light background, otherwise the configured dark
  theme. Orthogonal to *which* dark theme is configured.
- **Enhancements:** OSC-8 clickable links, auto light/dark detection, a
  `man-theme` switcher command, and section separator rules.
- **Core scope:** `man`, `dman`, `debman` (matches the stock plugin → drop-in).

## Architecture

### Components

1. **Plugin entrypoint** — `colored-man-pages-plus.plugin.zsh`
   Defines the `man` / `dman` / `debman` wrappers; resolves the active theme;
   exports the palette + feature flags + `MANPAGER` into the environment;
   registers the `man-theme` command. Thin glue, no rendering logic.

2. **Colorizer filter** — `lib/colorize.awk` (driven by `lib/shim.sh`)
   The engine. Reads groff-formatted man text on stdin, interprets overstrike
   (bold/underline) as hints, applies semantic role detection, emits ANSI
   (truecolor / 256 / 16), adds OSC-8 links and section rules, writes to stdout.
   Knows nothing about zsh — text in, colored text out. Independently testable.

3. **Theme palettes** — `themes/<name>.zsh`
   Each defines role→hex mappings for one theme. Pure data.

4. **Color resolver** — `lib/resolve-color.zsh`
   Converts hex → the correct ANSI escape for the terminal's color depth.

5. **Background detector** — `lib/detect-bg.zsh`
   OSC-11 query with timeout + TTY guard; returns light/dark for `auto`.

6. **`man-theme` command** — `lib/man-theme.zsh`
   List / live-preview / set the active theme.

### File layout

```
colored-man-pages-plus/
├── colored-man-pages-plus.plugin.zsh
├── lib/
│   ├── colorize.awk        # the engine
│   ├── shim.sh             # wires man → awk → less
│   ├── resolve-color.zsh
│   ├── detect-bg.zsh
│   └── man-theme.zsh
├── themes/
│   ├── dracula.zsh
│   ├── catppuccin.zsh
│   ├── gruvbox.zsh
│   ├── tokyonight.zsh
│   ├── light.zsh
│   └── ansi.zsh            # roles → terminal's 16 ANSI colors
│                           # 'auto' is mode logic, not a theme file
├── test/
│   ├── fixtures/           # captured groff output + expected ANSI
│   └── *.zsh               # plain-zsh + diff harness
└── docs/superpowers/specs/2026-06-08-colored-man-pages-plus-design.md
```

### Data flow

```
user: man grep
  └─ man() wrapper: resolve theme → export COLORED_MAN_PALETTE + flags
                    export MANPAGER="…/shim.sh | less -R"
       └─ command man grep            (man formats page via groff)
            └─ groff output ─stdin→ colorize.awk
                 • strip/interpret overstrike → attribute hints
                 • assign roles (header/command/flag/argument/path/literal/punct)
                 • emit ANSI + OSC-8 links + section rules
                 └─stdout→ less -R   (user sees colored page)
```

Everything is set per-invocation, so live theme changes and overrides take
effect on the next `man` call with no shell restart.

## Semantic roles

| Role        | Matches                                   | Detection signal                              |
|-------------|-------------------------------------------|-----------------------------------------------|
| `header`    | `NAME`, `SYNOPSIS`, top-level sections    | bold + left-aligned (col 0–1) + all-caps      |
| `subheader` | indented sub-sections                     | bold + all-caps, indented                     |
| `command`   | page's own command + cross-refs           | bold roman tokens, `name(N)` stems            |
| `flag`      | `-i`, `--ignore-case`                      | bold token matching `^--?[A-Za-z]`            |
| `argument`  | `PATTERNS`, `FILE`, placeholders          | italic/underline (groff renders args italic)  |
| `path`      | `/var/log`, `~/.config`                   | regex `(/[\w.-]+)+`, `~/…`                     |
| `literal`   | `'quoted'`, `"strings"`, examples         | quote-delimited spans                         |
| `punct`     | brackets, ellipses, commas in synopsis    | `[ ] \| . , …`                                |
| `default`   | body text                                 | everything else                               |

**Reliability principle:** bold/italic classification comes from groff, not from
us — we only *recolor* what groff already classified, then layer regex for the
finer distinctions (flag vs command, path, literal). Any unmatched line passes
through as plain text. Worst case = uncolored, never mangled.

## Theming

### Theme definition (pure data)

```zsh
# themes/dracula.zsh
typeset -gA COLORED_MAN_dracula=(
  header    "#bd93f9"   subheader "#bd93f9"
  command   "#8be9fd"   flag      "#ff79c6"
  argument  "#ffb86c"   path      "#50fa7b"
  literal   "#f1fa8c"   punct     "#6272a4"
  default   "#f8f8f2"
)
```

### Resolution & overrides (highest precedence wins)

1. **Per-role user override** — `COLORED_MAN_OVERRIDE[flag]="#ff0000"`
2. **Selected theme** — `zstyle ':colored-man:theme' name dracula` *or*
   `COLORED_MAN_THEME=dracula`. The special value `ansi` maps roles to the
   terminal's 16 ANSI colors. The special value `auto` enables background
   detection (below).
3. **`auto` mode** — `detect-bg.zsh` (OSC-11) selects the `light` theme on a
   light background, otherwise the configured/default dark theme.
4. **Fallback** — built-in dark default

The resolver converts each hex to ANSI at the terminal's real depth: truecolor
if `$COLORTERM` is `truecolor`/`24bit`, else nearest-256, else 16-color. Themes
are authored once in hex and degrade automatically.

### `auto` light/dark

`detect-bg.zsh` emits the OSC-11 query (`\e]11;?\e\\`) with a short read timeout,
**only** when stdin/stdout is an interactive TTY. It parses the returned
`rrrr/gggg/bbbb`, computes luminance, and returns light/dark. On any timeout,
non-TTY, or parse failure → defaults to dark. The result is cached per-shell to
avoid re-querying on every `man`.

## Enhancements

### OSC-8 hyperlinks
In `SEE ALSO` (and inline), `name(N)` cross-refs become clickable links
resolving to `man:name(N)`; bare URLs are wrapped too. Emitted only when the
terminal advertises OSC-8 support (or the `links` flag is on); otherwise text
renders normally — never broken escape codes.

### Section separator rules
Before each top-level `header` (except the first), emit a dim horizontal rule
sized to `$MANWIDTH`/`$COLUMNS`, drawn in the `punct` color.
Toggle: `COLORED_MAN_SEPARATORS=off` (default on).

### `man-theme` command
- `man-theme` / `man-theme list` — list themes, mark active
- `man-theme preview [name]` — render a bundled sample page through that theme
- `man-theme set <name>` — set for the session; `--save` appends the
  `zstyle`/export line to `~/.zshrc`

## Config surface (all optional)

```zsh
zstyle ':colored-man:theme' name dracula      # or COLORED_MAN_THEME=dracula
COLORED_MAN_OVERRIDE[flag]="#ff5555"          # per-role override
COLORED_MAN_SEPARATORS=off                    # default on
COLORED_MAN_LINKS=off                         # default auto-detect
```

Zero config required — sensible dark default, with `auto` available.

## Safety / fallbacks

- **`NO_COLOR` set** → pass through completely uncolored (respect the standard).
- **Not a TTY** (piped/redirected) → no color, no links, no rules.
- **Color depth** → truecolor → 256 → 16, automatic.
- **Custom `MANPAGER` already set by user** → not clobbered unless
  `COLORED_MAN_FORCE` is set; detect and warn once.
- **Engine is fail-safe** → any unmatched line passes through as plain text.
- **No `less`** → fall back to `$PAGER`/`more` with `-R` where supported.

## Testing (TDD, no external test deps)

- **Golden-file tests** (written first): captured groff output fixtures (`grep`,
  `git`, a synopsis-heavy page, a SEE-ALSO-heavy page) → run through
  `colorize.awk` → diff against expected ANSI. Core safety net.
- **Resolver unit tests**: hex→256 and hex→16 mappings assert exact escapes;
  truecolor passthrough.
- **Fallback tests**: `NO_COLOR`, non-TTY, depth downgrades, custom-MANPAGER
  detection.
- **Detection-rule tests**: targeted per-role fixtures (header vs subheader,
  flag vs command, path, literal) to pin down false positives.
- Harness is plain zsh + `diff` (runs anywhere omz runs; no `bats` dependency).

## Out of scope (YAGNI)

- Colorizing arbitrary `--help` output (not pager-fed; fragile).
- Solarized / Nord built-ins (can be added later as theme files).
- A GUI/TUI theme editor (the `man-theme preview` command covers experimentation).
