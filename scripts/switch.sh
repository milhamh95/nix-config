#!/bin/bash
# Rebuild the nix-darwin config for the current Mac.
#
# Usage:
#   bash scripts/switch.sh              # auto-detects host from `hostname -s`
#   bash scripts/switch.sh mac-desktop  # forces a specific host

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST="${1:-$(hostname -s)}"

cd "$SCRIPT_DIR/.."
sudo darwin-rebuild switch --flake ".#$HOST"
