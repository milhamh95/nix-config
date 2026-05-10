# Nix Config

Personal Nix configuration for macOS — manages system packages, dotfiles, and dev environment across 3 machines using a layered profile system.

> **Note:** This config is coupled with encrypted secrets (SSH keys, maven settings). Other people can still use this config by using the `-nosecrets` commands — see [Installation without secrets](#installation-without-secrets).

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

### Quick start (recommended)

Run the bootstrap script on a fresh Mac — it handles everything interactively:

```sh
curl -fsSL https://raw.githubusercontent.com/<username>/nix-config/main/scripts/bootstrap.sh -o bootstrap.sh
bash bootstrap.sh
```

The script will:
1. Install Xcode Command Line Tools (gives you `git` and `make`)
2. Clone the repo via HTTPS
3. Ask if you want to install with or without secrets
4. If with secrets — prompt for the path to your age key file
5. Ask which machine to install
6. Run the install

After install, restart your terminal and switch the git remote to SSH:

```sh
cd ~/nix/nix-config
git remote set-url origin git@personal:<username>/nix-config.git
```

<details>
<summary>Manual installation (step by step)</summary>

**1. Install Xcode Command Line Tools** (gives you `git` and `make`)

```sh
xcode-select --install
```

**2. Clone the repo via HTTPS** (SSH isn't set up yet)

```sh
mkdir ~/nix && cd ~/nix
git clone https://github.com/<username>/nix-config.git nix-config
cd nix-config
```

**3. Set up age key** (skip this step to install without secrets)

Save your age key from your password manager to `secrets/age/keys.txt`:

```sh
mkdir -p secrets/age
vim secrets/age/keys.txt   # paste the full key content, save and exit
```

**4. Run install**

```sh
# With secrets (age key required)
make install-desktop   # Mac Desktop
make install-mbp       # MacBook Pro (personal)
make install-alami     # Alami MacBook Pro (work)

# Without secrets (no age key needed)
make install-desktop-nosecrets
make install-mbp-nosecrets
make install-alami-nosecrets
```

**5. Switch git remote to SSH** (after secrets are decrypted)

```sh
git remote set-url origin git@personal:<username>/nix-config.git
```

</details>

<details>
<summary>First time setting up secrets (encrypting raw secrets)</summary>

Only needed once when building this repo from scratch — not on new machines.

```sh
# Put your raw secrets in secrets/raw/
mkdir -p secrets/raw
cp ~/.ssh/id_github_personal secrets/raw/id_github_personal
cp ~/.sdkman/candidates/maven/current/conf/settings.xml secrets/raw/maven_settings.xml

# Encrypt them — also generates the age key
make setup-secrets

# Copy the age key for backup
make export-age-key

# Back up secrets/age/keys.txt to your password manager
# You will need this key on every new machine

# Commit the encrypted files
git add secrets/*.enc .sops.yaml
git commit -m "feat: add encrypted secrets"
```

</details>

## Usage

Every command has a `-nosecrets` variant. Use the matching variant consistently — if you installed with `-nosecrets`, rebuild with `-nosecrets` too (until you set up your age key).

<details>
<summary>Rebuild commands</summary>

```sh
# Fish abbreviations (recommended)
nixmd      # rebuild mac-desktop
nixmbp     # rebuild mbp
nixalami   # rebuild alami-mbp

# Via Makefile (with secrets)
make switch-desktop
make switch-mbp
make switch-alami

# Via Makefile (without secrets)
make switch-desktop-nosecrets
make switch-mbp-nosecrets
make switch-alami-nosecrets
```

</details>

<details>
<summary>Other Makefile commands</summary>

```sh
make update             # update flake inputs
make check              # check configuration
make clean              # garbage collection
make setup-secrets      # encrypt raw secrets with sops/age
make export-age-key     # copy age key to secrets/age/ for backup
make help               # show all commands
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
