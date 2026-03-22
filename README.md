# Nook (`nk`)

Nook is a lightweight SSH bookmark manager for people who live in the terminal.

It gives your servers a clean home in one small Bash tool: searchable picker, grouped entries, SSH key setup, reachability checks, and a branded terminal experience that is ready for open-source distribution.

中文说明见 `README.zh-CN.md`.

## Why Nook

- Short primary command: `nk`
- Lightweight implementation with minimal dependencies
- Built for personal and small-team SSH workflows
- Keeps backward compatibility for the old `s` entrypoint without relying on a risky one-letter primary command

## Features

- Interactive server picker powered by `fzf`
- Grouped server catalog
- SSH key setup with `ssh-copy-id`
- Reachability check with `nc`
- Automatic migration from `~/.ssh-manager` to `~/.config/nook`
- `nk doctor` diagnostics for support and debugging

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/guyfar/nook-ssh/main/install.sh | bash
```

After installation, the primary command is `nk`.

Nook stores config in `~/.config/nook/` by default. If it finds an existing `~/.ssh-manager/` config, it migrates it automatically.

The old `s` command is kept as a compatibility alias, but the installer will not overwrite an existing unrelated `s` binary on the host.

## Preview

```text
$ nk
    _   __            __
   / | / /___  ____  / /__
  /  |/ / __ \/ __ \/ //_/
 / /|  / /_/ / /_/ / ,<
/_/ |_/\____/\____/_/|_|

  SSH jumpbox for humans

  [production]
    1) prod-web-01        1.2.3.4          :22    root     key  web node
    2) prod-db-01         1.2.3.6          :3306  root     pwd  primary db
```

## Usage

| Command | Description |
|------|------|
| `nk` | Open the interactive server picker |
| `nk add` | Add a server |
| `nk rm` | Remove a server |
| `nk list` | List all servers |
| `nk edit` | Edit the config file |
| `nk key` | Configure SSH key login |
| `nk ping` | Check server reachability |
| `nk doctor` | Show environment diagnostics |
| `nk <keyword>` | Search and connect |
| `nk version` | Show version |
| `nk help` | Show help |

Legacy alias:

| Command | Description |
|------|------|
| `s` | Old entrypoint kept for compatibility |

## Configuration

The default config file is:

```text
~/.config/nook/servers.conf
```

You can override the config directory with:

```bash
export NOOK_CONFIG_DIR=/path/to/custom-config-dir
```

Config format:

```conf
# Format : name | host | port | user | password(optional) | description

[production]
# prod-web-01 | 1.2.3.4 | 22 | root | yourpass | production web node
# prod-web-02 | 1.2.3.5 | 22 | root |          | production web node 2
# prod-db-01  | 1.2.3.6 | 3306 | root | dbpass123 | primary database
```

## SSH Key Setup

```bash
nk key
nk add
```

Nook detects an existing SSH public key automatically. If none exists, it generates an `ed25519` key and pushes it with `ssh-copy-id`.

## Dependencies

- `bash` 4.0+
- `fzf` optional, recommended
- `sshpass` optional, only needed for password-based login

```bash
# macOS
brew install fzf

# Debian / Ubuntu
sudo apt install fzf

# CentOS / RHEL
sudo yum install fzf
```

## Diagnostics

When someone reports an installation or connection issue, ask them to run:

```bash
nk doctor
```

This prints version, config paths, server count, and dependency availability for `ssh`, `fzf`, and `sshpass`.

## Development

```bash
# syntax check
bash -n nk s install.sh

# help
./nk help

# local install into temp directories
NOOK_INSTALL_DIR=/tmp/nook-bin XDG_CONFIG_HOME=/tmp/nook-xdg bash ./install.sh
```

See `CONTRIBUTING.md`, `CHANGELOG.md`, and `RELEASE_CHECKLIST.md` for project workflow details.

## Uninstall

```bash
sudo rm /usr/local/bin/nk
sudo rm /usr/local/bin/s
rm -rf ~/.config/nook
rm -rf ~/.ssh-manager
```

## License

MIT
