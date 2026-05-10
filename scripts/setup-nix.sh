#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Step 1: Install Xcode Command Line Tools
echo "Step 1: Checking Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo ""
    echo "Please wait for Xcode Command Line Tools installation to complete."
    echo "Press any key to continue after installation is done..."
    read -n 1
else
    echo "Xcode Command Line Tools already installed"
fi

# Step 2: Setup age key for sops-nix secrets decryption
echo ""
echo "Step 2: Setting up age key for secrets decryption..."

AGE_KEY_SRC="$SCRIPT_DIR/../secrets/age/keys.txt"
AGE_KEY_DEST="$HOME/Library/Application Support/sops/age/keys.txt"

if [ -f "$AGE_KEY_DEST" ]; then
    echo "Age key already installed ✅"
elif [ ! -f "$AGE_KEY_SRC" ]; then
    echo ""
    echo "⚠️  Age key not found at secrets/age/keys.txt"
    echo ""
    echo "To enable secrets decryption, place your age key at:"
    echo "  $SCRIPT_DIR/../secrets/age/keys.txt"
    echo ""
    echo "Retrieve it from your password manager. It looks like:"
    echo "  # created: ..."
    echo "  # public key: age1..."
    echo "  AGE-SECRET-KEY-1..."
    echo ""
    echo "Continuing without age key — secrets will not be decrypted."
    echo "Run the install script again after placing the key."
else
    if ! grep -q "AGE-SECRET-KEY-1" "$AGE_KEY_SRC"; then
        echo "⚠️  secrets/age/keys.txt does not look like a valid age key, skipping"
    else
        echo "Age key found, installing..."
        mkdir -p "$HOME/Library/Application Support/sops/age"
        cp "$AGE_KEY_SRC" "$AGE_KEY_DEST"
        chmod 600 "$AGE_KEY_DEST"
        echo "Age key installed ✅"
    fi
fi

# Step 3: Install Nix
echo ""
echo "Step 3: Checking Nix..."
if ! command -v nix &> /dev/null; then
    echo "Installing Nix..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.nixos.org/nix | \
      sh -s -- install

    # Source nix to make it available in current shell
    echo "Loading Nix into current shell..."
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
    echo "Nix already installed"
fi

# Step 4: Install Homebrew
echo ""
echo "Step 4: Checking Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for current shell
    echo "Loading Homebrew into current shell..."
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew already installed"
fi
