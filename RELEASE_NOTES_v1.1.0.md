# Nook v1.1.0

This is the first branded open-source release of Nook.

Nook turns the original single-script SSH manager into a more polished terminal tool with a stable primary command, branded TUI output, safer install behavior, diagnostics, and a cleaner open-source project surface.

## Highlights

- Introduced the `Nook` brand and the new primary command `nk`
- Added branded logo, help output, and picker framing
- Migrates existing config from `~/.ssh-manager` to `~/.config/nook`
- Added `nk doctor` for environment diagnostics
- Added open-source project metadata and contribution docs

## Migration Notes

- Primary command is `nk`
- Default config directory changed to `~/.config/nook`
- Existing users with `~/.ssh-manager` config are migrated automatically

## Verification

- `bash -n nk install.sh`
- `./nk doctor`
- `NOOK_INSTALL_DIR=/tmp/nook-bin XDG_CONFIG_HOME=/tmp/nook-xdg bash ./install.sh`

## Known Notes

- `nk` is intentionally short and memorable, but users in specialized environments may already have unrelated binaries with similar short names
- `sshpass` remains optional and is only needed for password-based SSH login
