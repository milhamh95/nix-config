#!/bin/bash

set -e

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

# Step 2: Install Nix
echo ""
echo "Step 2: Checking Nix..."
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

# Step 3: Install Homebrew
echo ""
echo "Step 3: Checking Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for current shell
    echo "Loading Homebrew into current shell..."
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew already installed"
fi
