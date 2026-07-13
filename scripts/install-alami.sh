#!/bin/bash

set -e

echo "Installing nix-darwin for: Alami MacBook Pro"
echo ""

# Run shared setup (Xcode + Nix + Homebrew)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$SCRIPT_DIR/setup-nix.sh"

# Load nix and homebrew into current shell (setup-nix.sh runs in a subshell)
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Step 5: Apply nix-darwin configuration
# Note: first run on a fresh machine may fail at sops-nix launchd setup;
# a second run succeeds once /run/current-system is established with GNU coreutils.
echo ""
echo "Step 5: Applying nix-darwin configuration..."
cd ~/nix/nix-config
if ! sudo env PATH="$PATH" nix run nix-darwin -- switch --flake .#alami-mbp; then
    echo ""
    echo "First activation attempt failed (expected on fresh install), retrying..."
    echo ""
    sudo env PATH="$PATH" nix run nix-darwin -- switch --flake .#alami-mbp
fi

echo ""
echo "Installation complete!"
echo "Please restart your terminal to use fish shell."
echo ""
echo "After restart, use 'nixalami' to rebuild your configuration."
