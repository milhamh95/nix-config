#!/bin/bash
# Rebuild the nix-darwin config for the current Mac.
#
# Usage:
#   bash scripts/switch.sh              # auto-detects host from `hostname -s`
#   bash scripts/switch.sh mac-desktop  # forces a specific host
#
# Set NIX_SKIP_SECRETS=1 to build without decrypting sops secrets
# (needs no age key — used by `make switch-nosecrets`).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST="${1:-$(hostname -s)}"

cd "$SCRIPT_DIR/.."

if [ "$NIX_SKIP_SECRETS" = "1" ]; then
    sudo env NIX_SKIP_SECRETS=1 darwin-rebuild switch --flake ".#$HOST" --impure
else
    sudo darwin-rebuild switch --flake ".#$HOST"
fi
