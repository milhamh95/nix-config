# Nix Config

Personal Nix configuration for macOS — manages system packages, dotfiles, and dev environment across 3 machines using a layered profile system.

> For a more advanced nix config, check out [github.com/r17x/universe](https://github.com/r17x/universe)

## Machines

| Machine | Profiles | Use |
|---|---|---|
| `mac-desktop` | work, alami | Main desktop |
| `mbp` | — | Personal laptop (minimal) |
| `alami-mbp` | work, alami | Work laptop |

Each machine always gets the `common` layer. Profiles are opt-in on top of that. See [Architecture](docs/architecture.md) for details.

## Prerequisites

1. **Login to Mac App Store** — required for `mas` to install App Store apps
2. **Full Disk Access for Terminal** — System Settings → Privacy & Security → Full Disk Access

## Installation

```sh
mkdir ~/nix && cd ~/nix
git clone <repo-url> nix-config
cd nix-config

make install-desktop   # Mac Desktop
make install-mbp       # MacBook Pro (personal)
make install-alami     # Alami MacBook Pro (work)
```

Restart your terminal after installation to use fish shell.

## Usage

<details>
<summary>Rebuild commands</summary>

```sh
# Fish abbreviations (recommended)
nixmd      # rebuild mac-desktop
nixmbp     # rebuild mbp
nixalami   # rebuild alami-mbp

# Or via Makefile
make switch-desktop
make switch-mbp
make switch-alami
```

</details>

<details>
<summary>Other Makefile commands</summary>

```sh
make update   # update flake inputs
make check    # check configuration
make clean    # garbage collection
make help     # show all commands
```

</details>

## Maintenance

<details>
<summary>Garbage collection & generations</summary>

```sh
# View all generations
darwin-rebuild --list-generations

# Clean generations older than 7 days
nix-collect-garbage --delete-older-than 7d
sudo nix-collect-garbage --delete-older-than 7d

# Clean all (or: make clean)
nix-collect-garbage -d
sudo nix-collect-garbage -d
```

</details>

## Documentation

- [Architecture](docs/architecture.md) — layer system, directory structure, per-machine config
- [Secrets Management](docs/secrets-management.md) — SSH keys, sops/age setup
- [Paid Apps](docs/paid-apps.md) — license info and device limits

## Reference

- [github.com/r17x/universe](https://github.com/r17x/universe)
- [github.com/torgeir/nix-darwin](https://github.com/torgeir/nix-darwin)
- [github.com/linkarzu/dotfiles-latest](https://github.com/linkarzu/dotfiles-latest)
