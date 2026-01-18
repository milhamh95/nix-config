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
5. **Rebuild** with `make switch-desktop` or `make switch-mbp`

> **Security Tip:** Don't use `echo "secret" > file` in terminal - it saves to shell history. Use a text editor instead (vim, nano, VS Code).

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

#### Step 4: Add sops config to home-manager

Edit `common/home-manager.nix` and add your secret:

```nix
# Sops secrets configuration
sops = {
  age.keyFile = "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt";

  secrets.id_github_personal = {
    sopsFile = ../secrets/id_github_personal.enc;
    format = "binary";
    path = "${config.home.homeDirectory}/.ssh/id_github_personal";
    mode = "0600";
  };
};
```

#### Step 5: Commit encrypted file

```bash
git add secrets/id_github_personal.enc .sops.yaml
git commit -m "Add encrypted SSH private key"
```

#### Step 6: Rebuild

```bash
make switch-desktop  # or make switch-mbp
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

#### Step 3: Add to home-manager

Edit `common/home-manager.nix`:

```nix
sops = {
  age.keyFile = "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt";

  secrets.id_github_personal = {
    sopsFile = ../secrets/id_github_personal.enc;
    format = "binary";
    path = "${config.home.homeDirectory}/.ssh/id_github_personal";
    mode = "0600";
  };

  # Add API key
  secrets.claude_api_key = {
    sopsFile = ../secrets/claude_api_key.enc;
    format = "binary";
    path = "${config.home.homeDirectory}/.config/secrets/claude_api_key";
    mode = "0600";
  };
};
```

#### Step 4: Commit and rebuild

```bash
git add secrets/claude_api_key.enc
git commit -m "Add encrypted Claude API key"
make switch-desktop
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

### 3. Add all to home-manager.nix

```nix
sops = {
  age.keyFile = "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt";

  secrets.id_github_personal = {
    sopsFile = ../secrets/id_github_personal.enc;
    format = "binary";
    path = "${config.home.homeDirectory}/.ssh/id_github_personal";
    mode = "0600";
  };

  secrets.id_github_work = {
    sopsFile = ../secrets/id_github_work.enc;
    format = "binary";
    path = "${config.home.homeDirectory}/.ssh/id_github_work";
    mode = "0600";
  };

  secrets.claude_api_key = {
    sopsFile = ../secrets/claude_api_key.enc;
    format = "binary";
    path = "${config.home.homeDirectory}/.config/secrets/claude_api_key";
    mode = "0600";
  };

  secrets.openai_api_key = {
    sopsFile = ../secrets/openai_api_key.enc;
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
make switch-desktop
```

---

## Host-Specific Secrets

Some secrets should only be available on specific machines. For example, a work SSH key that should only exist on your desktop, not your laptop.

### Architecture

- **Common secrets**: Configured in `common/home-manager.nix` - available on all hosts
- **Host-specific secrets**: Configured in `hosts/<hostname>/home-manager.nix` - only available on that host

### Example: Work SSH Key (mac-desktop only)

#### Step 1: Create the secret file

```bash
vim secrets/raw/id_github_alami_group
# Paste your private key content, save and exit
```

#### Step 2: Encrypt

```bash
make setup-secrets
```

#### Step 3: Add public key to app-config

Create the public key file:

```bash
# Copy your public key
cp ~/.ssh/id_github_alami_group.pub app-config/hosts/mac-desktop/ssh/id_github_alami_group.pub
```

#### Step 4: Add to host-specific home-manager.nix

Edit `hosts/mac-desktop/home-manager.nix` (NOT `common/home-manager.nix`):

```nix
{ config, pkgs, lib, ... }:

{
  # Sops secrets configuration (mac-desktop only)
  sops.secrets.id_github_alami_group = {
    sopsFile = ../../secrets/id_github_alami_group.enc;
    format = "binary";
    path = "${config.home.homeDirectory}/.ssh/id_github_alami_group";
    mode = "0600";
  };

  # ... rest of the file
}
```

#### Step 5: Add activation script for SSH config

Also in `hosts/mac-desktop/home-manager.nix`, add an activation script:

```nix
home.activation.configureWorkSsh = lib.hm.dag.entryAfter ["writeBoundary"] ''
  echo "Configuring work SSH..."
  $DRY_RUN_CMD mkdir -p "$HOME/.ssh"
  $DRY_RUN_CMD cp ${../../app-config/hosts/mac-desktop/ssh/id_github_alami_group.pub} "$HOME/.ssh/id_github_alami_group.pub"
  $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_github_alami_group.pub"

  # Append work SSH config if not already present
  if ! grep -q "Host alami-group" "$HOME/.ssh/config" 2>/dev/null; then
    echo "" >> "$HOME/.ssh/config"
    $DRY_RUN_CMD cat ${../../app-config/hosts/mac-desktop/ssh/config} >> "$HOME/.ssh/config"
  fi
  echo "Work SSH configured"
'';
```

#### Step 6: Commit and rebuild

```bash
git add secrets/id_github_alami_group.enc app-config/hosts/mac-desktop/ssh/
git commit -m "Add work SSH key (mac-desktop only)"
make switch-desktop
```

#### Step 7: Verify

```bash
# Check files exist
ls -la ~/.ssh/id_github_alami_group
ls -la ~/.ssh/id_github_alami_group.pub

# Check SSH config
grep -A7 "alami-group" ~/.ssh/config

# Test connection
ssh -T git@alami-group
```

On mbp, the secret will NOT be decrypted (no `~/.ssh/id_github_alami_group` file).

---

## Setting Up on a New Machine

1. Clone this repo
2. Copy your age key to:
   ```
   ~/Library/Application Support/sops/age/keys.txt
   ```
3. Run:
   ```bash
   make switch-desktop  # or make switch-mbp
   ```
4. Done - secrets are automatically decrypted

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
└── common/
    └── home-manager.nix          ← sops decryption config
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
