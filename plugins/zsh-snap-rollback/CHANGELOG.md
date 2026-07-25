# Changelog

All notable changes to this plugin are documented here.

---

## [1.2] — 2026-04-12

### Changed
- Auto-detect sudo requirement — uses `snapper` directly if user has access via ALLOW_USERS/ALLOW_GROUPS, falls back to `sudo snapper` otherwise

## [1.1] — 2026-04-12

### Changed
- Replaced `│`-based parsing with `snapper --csvout --separator '|' --no-headers list --columns` — locale-independent, immune to Snapper rendering changes
- Added post-rollback exit code check — "✓ Rollback complete" only displayed on actual success
- Added `snap-list` availability check — falls back to `sudo snapper list` if snap-list is not installed

## [1.0] — 2026-04-12

### Added
- Initial release — safe guided snapper rollback for openSUSE Tumbleweed
- `snap-rollback` — no argument: calls `snap-list -a` then shows how to proceed
- `snap-rollback <id>` — shows target snapshot info (date, type, importance, description) with `[y/N]` confirmation
- `snap-rollback <id> --dry-run` — simulate without executing
- Explicit irreversibility warning before confirmation
- Reboot reminder after successful rollback
- Full English interface, consistent `[y/N]` prompts
