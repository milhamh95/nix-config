# Nix Config

Personal Nix configuration for macOS — manages system packages, dotfiles, and dev environment across 3 machines using a layered profile system.

> For a more advanced nix config, check out [github.com/r17x/universe](https://github.com/r17x/universe)

## Machines

| Machine | Profiles | Use |
|---|---|---|
| `mac-desktop` | work | Main desktop |
| `mbp` | laptop | Personal laptop (minimal) |

Each machine always gets the `common` layer. Profiles are opt-in on top of that. See [Architecture](docs/architecture.md) for details.

## Prerequisites

1. **Login to Mac App Store** — required for `mas` to install App Store apps
2. **Full Disk Access for Terminal** — System Settings → Privacy & Security → Full Disk Access
   > **Important:** After granting Full Disk Access, **quit and reopen Terminal** (Cmd+Q) before running any install command. The permission only applies to new Terminal sessions — the Nix installer will fail with a "Read-only file system" error if the terminal wasn't restarted.

## Installation

### Quick start (recommended)

Run the bootstrap script on a fresh Mac — it handles everything interactively:

```sh
curl -fsSL https://raw.githubusercontent.com/milhamh95/nix-config/feat/separate-brew/scripts/bootstrap.sh -o bootstrap.sh
bash bootstrap.sh              # clones main branch (default)
bash bootstrap.sh feat/my-branch  # clones a specific branch
```

The script will:
1. Install Xcode Command Line Tools (gives you `git` and `make`)
2. Clone the repo via HTTPS (from the specified branch, defaults to `main`)
3. Prompt for the path to your age key file
4. Ask which machine to install
5. Run the install

After install, restart your terminal and switch the git remote to SSH:

```sh
cd ~/nix/nix-config
git remote set-url origin git@personal:milhamh95/nix-config.git
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
git clone https://github.com/milhamh95/nix-config.git nix-config
cd nix-config
```

**3. Set up age key**

Save your age key from your password manager to `secrets/age/keys.txt`:

```sh
mkdir -p secrets/age
vim secrets/age/keys.txt   # paste the full key content, save and exit
```

**4. Run install**

```sh
make install-desktop   # Mac Desktop
make install-mbp       # MacBook Pro (personal)
```

**5. Switch git remote to SSH** (after secrets are decrypted)

```sh
git remote set-url origin git@personal:milhamh95/nix-config.git
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

<details>
<summary>Rebuild commands</summary>

```sh
# Fish abbreviations (recommended)
nixmd      # rebuild mac-desktop
nixmbp     # rebuild mbp

# Via Makefile
make switch-desktop
make switch-mbp
```

</details>

<details>
<summary>Dev shells</summary>

```sh
nix develop .#postgres   # PostgreSQL 17 dev shell (auto-enters fish)
nix develop .#redis      # Redis dev shell (auto-enters fish)

# Or use fish abbreviations
pgshell
rdshell
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
