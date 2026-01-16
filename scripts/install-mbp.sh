#!/bin/bash

set -e

echo "Installing nix-darwin for: MacBook Pro"
echo ""

# Run shared setup (Xcode + Nix)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$SCRIPT_DIR/setup-nix.sh"

# Step 3: Apply nix-darwin configuration
echo ""
echo "Step 3: Applying nix-darwin configuration..."
cd ~/nix/nix-config
nix run nix-darwin -- switch --flake .#mbp

echo ""
echo "Installation complete!"
echo "Please restart your terminal to use fish shell."
echo ""
echo "After restart, use 'nixmbp' to rebuild your configuration."
