# Secrets Management with sops-nix

This guide explains how to securely store and manage secrets (SSH keys, API keys, etc.) in this repository using [sops-nix](https://github.com/Mic92/sops-nix).

## Table of Contents

- [How It Works](#how-it-works)
- [Prerequisites](#prerequisites)
- [General Workflow](#general-workflow)
- [Examples](#examples)
  - [Example 1: GitHub SSH Private Key](#example-1-github-ssh-private-key)
  - [Example 2: API Key (e.g., Claude, OpenAI)](#example-2-api-key-eg-claude-openai)
- [Adding Multiple Secrets](#adding-multiple-secrets)
- [Host-Specific Secrets](#host-specific-secrets)
- [Setting Up on a New Machine](#setting-up-on-a-new-machine)
- [File Structure](#file-structure)
- [Troubleshooting](#troubleshooting)

---

## How It Works

```
┌─────────────────────────────────────────────────────────────────────┐
│  age key (master key)                                               │
│  Location: ~/Library/Application Support/sops/age/keys.txt         │
│                                                                     │
│  This ONE key encrypts/decrypts ALL your secrets                    │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              │ unlocks
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│  secrets/id_github_personal.enc    ← encrypted SSH key              │
│  secrets/claude_api_key.enc        ← encrypted API key              │
│                                                                     │
│  All encrypted files are safe to commit to git                      │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              │ darwin-rebuild switch
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│  ~/.ssh/id_github_personal              ← decrypted automatically   │
│  ~/.config/secrets/claude_api_key       ← decrypted automatically   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

- nix-darwin installed
- This repo cloned

---

## General Workflow

For any secret, the workflow is always the same:

1. **Create a plain text file** in `secrets/raw/` containing your secret
2. **Run** `make setup-secrets` to encrypt
3. **Configure** home-manager to decrypt it
4. **Commit** the `.enc` file (never commit raw files)
5. **Rebuild** with `make switch`

> **Security Tip:** Don't use `echo "secret" > file` in terminal - it saves to shell history. Use a text editor instead (vim, nano, VS Code).

### Skipping secrets entirely

No age key, or just trying this config out on a throwaway Mac? Append
`-nosecrets` to install or switch and sops decryption is skipped completely
— `make install-mbp-nosecrets`, `make install-desktop-nosecrets`,
`make switch-nosecrets`. Everything else in the config still builds; only
`~/.ssh/id_github_personal` (and any other secret you add) won't be written.

Under the hood this passes `NIX_SKIP_SECRETS=1` and `--impure` to
`darwin-rebuild` — see `modules/features/sops.nix`. A plain
`darwin-rebuild switch --flake .` (no env var, no `--impure`) always keeps
secrets on, so forgetting the flag never silently skips them.

---

## Examples

### Example 1: GitHub SSH Private Key

#### Step 1: Put your private key in secrets folder

```bash
# Option A: Copy existing key
cp ~/.ssh/id_github_personal secrets/raw/id_github_personal

# Option B: Create new file with editor (more secure)
vim secrets/raw/id_github_personal
# Paste your private key content, save and exit
```

The file content should look like:

```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAA...
...
-----END OPENSSH PRIVATE KEY-----
```

#### Step 2: Run setup (generates age key + encrypts)

```bash
make setup-secrets
```

This will:
1. Generate age key (if not exists)
2. Update `.sops.yaml` with your public key
3. Encrypt all files in `secrets/raw/`

#### Step 3: Backup your age key

**This is critical!** If you lose this key, you cannot decrypt your secrets.

```
Location: ~/Library/Application Support/sops/age/keys.txt
```

Save it to your password manager (1Password, Bitwarden, etc.)

#### Step 4: Add sops config

Edit `modules/features/sops.nix` and add your secret:

```nix
sops.secrets.id_github_personal = {
  sopsFile = inputs.self + "/secrets/id_github_personal.enc";
  format = "binary";
  path = "${config.home.homeDirectory}/.ssh/id_github_personal";
  mode = "0600";
};
```

(`sops.age.keyFile` and the `sops-nix.homeManagerModules.sops` import are
already set up in that file — you're only adding a `secrets.<name>` entry.)

#### Step 5: Commit encrypted file

```bash
git add secrets/id_github_personal.enc .sops.yaml
git commit -m "Add encrypted SSH private key"
```

#### Step 6: Rebuild

```bash
make switch
```

#### Step 7: Verify

```bash
ssh -T git@personal
# Expected: Hi <username>! You've successfully authenticated...
```

---

### Example 2: API Key (e.g., Claude, OpenAI)

#### Step 1: Create a file with your API key

Open your editor and create the file:

```bash
vim secrets/raw/claude_api_key
```

Paste **only** the API key value (no quotes, no key name):

```
sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Save and exit.

> **Note:** The file extension doesn't matter. You can use `.txt` if you prefer:
> `secrets/raw/claude_api_key.txt`

#### Step 2: Encrypt

```bash
make setup-secrets
```

This creates `secrets/claude_api_key.enc` (or `secrets/claude_api_key.txt.enc`).

#### Step 3: Add to sops.nix

Edit `modules/features/sops.nix`, add another entry next to
`id_github_personal`:

```nix
sops.secrets.claude_api_key = {
  sopsFile = inputs.self + "/secrets/claude_api_key.enc";
  format = "binary";
  path = "${config.home.homeDirectory}/.config/secrets/claude_api_key";
  mode = "0600";
};
```

#### Step 4: Commit and rebuild

```bash
git add secrets/claude_api_key.enc
git commit -m "Add encrypted Claude API key"
make switch
```

#### Step 5: Use the API key

After rebuild, the decrypted key is available at `~/.config/secrets/claude_api_key`.

```bash
# Read the key
cat ~/.config/secrets/claude_api_key

# Export as environment variable
export ANTHROPIC_API_KEY=$(cat ~/.config/secrets/claude_api_key)

# Or add to your shell config (.zshrc)
export ANTHROPIC_API_KEY=$(cat ~/.config/secrets/claude_api_key)
```

---

## Adding Multiple Secrets

You can add as many secrets as you need. Each secret is a separate file.

### 1. Create raw files

```bash
# Use editor for each file
vim secrets/raw/claude_api_key
vim secrets/raw/openai_api_key
vim secrets/raw/id_github_work
```

### 2. Encrypt all at once

```bash
make setup-secrets
```

### 3. Add all to `modules/features/sops.nix`

```nix
sops.secrets = {
  id_github_personal = {
    sopsFile = inputs.self + "/secrets/id_github_personal.enc";
    format = "binary";
    path = "${config.home.homeDirectory}/.ssh/id_github_personal";
    mode = "0600";
  };

  id_github_work = {
    sopsFile = inputs.self + "/secrets/id_github_work.enc";
    format = "binary";
    path = "${config.home.homeDirectory}/.ssh/id_github_work";
    mode = "0600";
  };

  claude_api_key = {
    sopsFile = inputs.self + "/secrets/claude_api_key.enc";
    format = "binary";
    path = "${config.home.homeDirectory}/.config/secrets/claude_api_key";
    mode = "0600";
  };

  openai_api_key = {
    sopsFile = inputs.self + "/secrets/openai_api_key.enc";
    format = "binary";
    path = "${config.home.homeDirectory}/.config/secrets/openai_api_key";
    mode = "0600";
  };
};
```

### 4. Commit and rebuild

```bash
git add secrets/*.enc
git commit -m "Add encrypted secrets"
make switch
```

---

## Host-Specific Secrets

Some secrets should only be available on specific machines. For example, a work SSH key that should only exist on your desktop, not your laptop.

### Architecture

- **Common secrets**: Configured in `modules/features/sops.nix` — every
  aspect it defines is included by `common`, so it reaches both hosts.
- **Host-specific secrets**: Add the `sops.secrets.*` entry directly in
  `modules/hosts/<hostname>.nix` instead, under
  `den.aspects.<hostname>.provides.to-users.homeManager` — same trap as any
  other host-scoped `home.file`/`home.activation`: it must go through
  `provides.to-users`, plain `homeManager` on a host aspect is inert.

### Example: Work SSH key (mac-desktop only)

#### Step 1: Create the secret file

```bash
vim secrets/raw/id_github_work_group
# Paste your private key content, save and exit
```

#### Step 2: Encrypt

```bash
make setup-secrets
```

#### Step 3: Add the public key to dotfiles

```bash
mkdir -p dotfiles/mac-desktop/ssh
cp ~/.ssh/id_github_work_group.pub dotfiles/mac-desktop/ssh/id_github_work_group.pub
```

#### Step 4: Add to `modules/hosts/mac-desktop.nix`

```nix
{ inputs, den, self, config, lib, ... }:
{
  # ... existing mac-desktop config ...

  den.aspects.mac-desktop.provides.to-users.homeManager =
    { config, lib, ... }:
    {
      sops.secrets.id_github_work_group = {
        sopsFile = inputs.self + "/secrets/id_github_work_group.enc";
        format = "binary";
        path = "${config.home.homeDirectory}/.ssh/id_github_work_group";
        mode = "0600";
      };

      home.file.".ssh/id_github_work_group.pub".source =
        inputs.self + "/dotfiles/mac-desktop/ssh/id_github_work_group.pub";

      # ... rest of the mac-desktop homeManager block ...
    };
}
```

#### Step 5: Commit and rebuild

```bash
git add secrets/id_github_work_group.enc dotfiles/mac-desktop/ssh/
git commit -m "Add work SSH key (mac-desktop only)"
make switch
```

#### Step 6: Verify

```bash
ls -la ~/.ssh/id_github_work_group        # should exist, permissions 600
ls -la ~/.ssh/id_github_work_group.pub
```

To also wire up an SSH `Host` block (so `git@work-group` resolves), add a
`programs.ssh.settings."work-group" = { ... }` entry alongside the secret in
the same homeManager block — see `modules/features/ssh.nix` for the pattern
already used for `github.com`. Aspects merge, so a host-only match block does
not need any activation-script text-appending.

On mbp, the secret will NOT be decrypted (no `~/.ssh/id_github_work_group` file).

---

## Setting Up on a New Machine

The install scripts handle the age key automatically — you just need to place it in the repo before running install.

### Step 1: Clone the repo

```bash
mkdir ~/nix && cd ~/nix
git clone <repo-url> nix-config
cd nix-config
```

### Step 2: Place your age key

Retrieve your age key from your password manager. It looks like this:

```
# created: 2024-01-01T00:00:00+07:00
# public key: age1vfhs5y5nmtmw9n9tq5eqtx07a5u8j2qfjenjj08dmalaccesmq9quzctvw
AGE-SECRET-KEY-1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

Create the file at `secrets/age/keys.txt` in the repo (this folder is gitignored — it will never be committed):

```bash
mkdir -p secrets/age
vim secrets/age/keys.txt   # paste the full key content, save and exit
```

### Step 3: Run install

```bash
make install-desktop   # or install-mbp
```

The install script will automatically:
1. Validate the age key
2. Copy it to `~/Library/Application Support/sops/age/keys.txt`
3. Install Nix + Homebrew
4. Apply nix-darwin → sops decrypts all secrets automatically

### Step 4: Verify

After rebuild, check that secrets were decrypted:

```bash
ls -la ~/.ssh/id_github_personal        # should exist, permissions 600
```

---

## File Structure

```
nix-config/
├── .sops.yaml                    ← sops configuration (which age key to use)
├── secrets/
│   ├── raw/                      ← raw secrets (gitignored, temporary)
│   │   ├── id_github_personal    ← your SSH private key
│   │   └── claude_api_key        ← your API key
│   ├── id_github_personal.enc    ← encrypted SSH key (safe to commit)
│   └── claude_api_key.enc        ← encrypted API key (safe to commit)
└── modules/
    └── features/
        └── sops.nix               ← sops decryption config, in `common`
```

---

## Troubleshooting

### "No matching creation rules found"

Make sure `.sops.yaml` exists and has your age public key:

```yaml
keys:
  - &user_age age1your_public_key_here

creation_rules:
  - path_regex: secrets/raw/.*
    key_groups:
      - age:
          - *user_age
```

### "Failed to decrypt"

1. Check if age key exists:
   ```bash
   cat ~/Library/Application\ Support/sops/age/keys.txt
   ```

2. Verify the public key in `.sops.yaml` matches your age key

### SSH key not working after rebuild

1. Check if key was decrypted:
   ```bash
   ls -la ~/.ssh/id_github_personal
   ```

2. Check permissions (should be 0600):
   ```bash
   chmod 600 ~/.ssh/id_github_personal
   ```

### API key file is empty

1. Check if sops decrypted the file:
   ```bash
   cat ~/.config/secrets/claude_api_key
   ```

2. Verify the encrypted file exists:
   ```bash
   ls -la secrets/claude_api_key.enc
   ```

3. Try manual decryption to test:
   ```bash
   sops --decrypt secrets/claude_api_key.enc
   ```
