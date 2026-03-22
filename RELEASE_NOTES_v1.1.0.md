# Nook v1.1.0

This is the first branded open-source release of Nook.

Nook turns the original single-script SSH manager into a more polished terminal tool with a stable primary command, branded TUI output, safer install behavior, diagnostics, and a cleaner open-source project surface.

## Highlights

- Introduced the `Nook` brand and the new primary command `nk`
- Kept `s` as a legacy compatibility alias
- Added branded logo, help output, and picker framing
- Migrates existing config from `~/.ssh-manager` to `~/.config/nook`
- Added `nk doctor` for environment diagnostics
- Improved installer behavior to avoid overwriting unrelated `s` binaries
- Added open-source project metadata and contribution docs

## Migration Notes

- Recommended command changed from `s` to `nk`
- Default config directory changed to `~/.config/nook`
- Existing users with `~/.ssh-manager` config are migrated automatically
- The installer still supports the old alias when it is safe to install

## Verification

- `bash -n nk s install.sh`
- `./nk doctor`
- `NOOK_INSTALL_DIR=/tmp/nook-bin XDG_CONFIG_HOME=/tmp/nook-xdg bash ./install.sh`

## Known Notes

- `nk` is intentionally short and memorable, but users in specialized environments may already have unrelated binaries with similar short names
- `sshpass` remains optional and is only needed for password-based SSH login
