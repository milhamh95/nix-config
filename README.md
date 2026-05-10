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

**1. Clone the repo**

```sh
mkdir ~/nix && cd ~/nix
git clone <repo-url> nix-config
cd nix-config
```

**2. Set up secrets**

<details>
<summary>First time setting up this repo</summary>

This step generates the age key and encrypts your secrets into `.enc` files that get committed to git.

```sh
# Put your raw secrets in secrets/raw/
# (GitHub SSH key, maven settings, etc.)
mkdir -p secrets/raw
cp ~/.ssh/id_github_personal secrets/raw/id_github_personal
cp ~/.sdkman/candidates/maven/current/conf/settings.xml secrets/raw/maven_settings.xml

# Encrypt them — also generates the age key
make setup-secrets

# Copy the age key to secrets/age/ so the install script can find it
make export-age-key

# Back up secrets/age/keys.txt to your password manager (1Password, Bitwarden, etc.)
# You will need this key on every new machine

# Commit the encrypted files
git add secrets/*.enc .sops.yaml
git commit -m "feat: add encrypted secrets"
```

Then continue to step 3.

</details>

<details>
<summary>Setting up on a new machine</summary>

The `.enc` files are already in git. You just need the age key to decrypt them.

```sh
# Retrieve your age key from your password manager
# and place it at secrets/age/keys.txt
mkdir -p secrets/age
vim secrets/age/keys.txt   # paste the full key content, save and exit
```

Then continue to step 3.

</details>

**3. Run install**

```sh
make install-desktop   # Mac Desktop
make install-mbp       # MacBook Pro (personal)
make install-alami     # Alami MacBook Pro (work)
```

The install script will automatically copy the age key to the correct location, then apply the nix-darwin config — sops decrypts all secrets during this step.

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
