#!/bin/bash

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
source ~/.bash_profile

echo "cd to nix-config directory..."
cd /etc/nix-config

echo "Applying nix-darwin configuration..."
nix run nix-darwin -- switch --flake .#mac
