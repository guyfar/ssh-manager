# Contributing

Thanks for contributing to Nook.

## Development Principles

- Keep the project lightweight and dependency-minimal.
- Prefer portable Bash over shell tricks that only work on one platform.
- Treat `nk` as the primary user-facing command.
- Preserve backward compatibility for existing `s` users where it is low-cost.

## Local Checks

Run these before opening a PR:

```bash
bash -n nk s install.sh
./nk help
./nk version
NOOK_INSTALL_DIR=/tmp/nook-bin XDG_CONFIG_HOME=/tmp/nook-xdg bash ./install.sh
```

## Style Notes

- Use ASCII unless a file already relies on Unicode.
- Keep output concise and readable in narrow terminals.
- Prefer explicit, predictable shell code over clever one-liners.

## Pull Requests

- Explain the user-facing change.
- Mention any compatibility impact.
- Include manual verification steps if behavior changed.
