#!/bin/bash

echo "Choose your nix-darwin configuration:"
echo "1) Mac Desktop"
echo "2) MacBook Pro"
read -p "Enter your choice (1 or 2): " choice

case $choice in
  1)
    config="mac-desktop"
    ;;
  2)
    config="mbp"
    ;;
  *)
    echo "Invalid choice. Exiting..."
    exit 1
    ;;
esac

echo "Checking for Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Please wait for Xcode Command Line Tools installation to complete and press any key to continue..."
    read -n 1
else
    echo "Xcode Command Line Tools already installed"
fi

echo "Installing Nix..."
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
  sh -s -- install

echo "Reload Terminal..."
exec zsh

# make sure it's in nix-config folder
echo "cd to nix-config directory..."
cd ~/nix/nix-config

echo "Applying nix-darwin configuration..."
nix run nix-darwin -- switch --flake .#"$config"
