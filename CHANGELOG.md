# Changelog

All notable changes to this project will be documented in this file.

The format loosely follows Keep a Changelog.

## [Unreleased]

- No unreleased changes yet.

## [1.1.0] - 2026-03-22

### Added

- Introduced the `Nook` brand and the new primary command `nk`.
- Added a branded ASCII logo, help output, and TUI framing.
- Added automatic migration from `~/.ssh-manager` to `~/.config/nook`.
- Added `nk doctor` for environment diagnostics.
- Added OSS project metadata files: `LICENSE`, `CONTRIBUTING.md`, and `RELEASE_CHECKLIST.md`.

### Changed

- Replaced the old one-letter `s` entrypoint with `nk` as the recommended command.
- Kept `s` as a compatibility alias instead of the primary implementation.
- Updated installer and README to reflect the new brand and config layout.
- Reworked config editing logic to avoid the previous macOS-only `sed -i ''` approach.
