# zsh-snap-rollback

[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-openSUSE%20Tumbleweed-green.svg)](https://get.opensuse.org/tumbleweed/)
[![Shell](https://img.shields.io/badge/shell-zsh-blue.svg)](https://www.zsh.org/)
[![Oh My Zsh](https://img.shields.io/badge/Oh%20My%20Zsh-plugin-blueviolet.svg)](https://ohmyz.sh/)

> Oh My Zsh plugin for openSUSE Tumbleweed — Safe guided snapper rollback with confirmation and reboot warning.

Part of the [zsh-opensuse-tumbleweed](https://github.com/crisis1er/zsh-opensuse-tumbleweed) ecosystem.

---

## Why zsh-snap-rollback?

Native `snapper rollback` executes immediately with no safety checks. This plugin adds:

- **Guided flow** — calls `snap-list -a` first so you see all snapshots before choosing
- **Snapshot summary** — shows date, type, importance, and description of the target before acting
- **Double confirmation** — explicit `[y/N]` prompt with clear irreversibility warning
- **Dry-run mode** — simulate the rollback without executing it
- **Reboot reminder** — rollback requires a reboot; the plugin always reminds you

---

## Requirements

- openSUSE Tumbleweed
- [Oh My Zsh](https://ohmyz.sh/)
- `snapper` installed and configured
- [zsh-snap-list](https://github.com/crisis1er/zsh-snap-list) plugin installed (for the guided display)
- `sudo` access

---

## Installation

```zsh
git clone https://github.com/crisis1er/zsh-snap-rollback \
  ~/.oh-my-zsh/custom/plugins/snap-rollback
```

Add `snap-rollback` to your plugins list in `~/.zshrc`:

```zsh
plugins=(... snap-list snap-rollback)
```

Reload:

```zsh
source ~/.zshrc
```

---

## Usage

```
snap-rollback                    # show all snapshots, then wait for your choice
snap-rollback <id>               # guided rollback to snapshot <id>
snap-rollback <id> --dry-run     # simulate — no action taken
```

### Examples

```zsh
snap-rollback          # lists all snapshots via snap-list -a
snap-rollback 12       # rollback to snapshot #12 with confirmation
snap-rollback 12 --dry-run
```

---

## Workflow

```
snap-rollback
  └─ calls snap-list -a          (shows all configs with colors + summary)
  └─ user picks a number
  └─ snap-rollback <number>
       └─ shows target info (date / type / importance / description)
       └─ [y/N] confirm
       └─ executes snapper rollback
       └─ reminds to reboot
```

---

## License

[GNU General Public License v3.0](LICENSE)

---

## Maintainer

[SafeITExperts](https://github.com/crisis1er) — safeitexperts@safeitexperts.com
