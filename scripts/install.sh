#!/bin/bash
# Bootstrap script for setting up nix-config on a fresh Mac.
#
# Usage (no git or clone needed):
#   curl -fsSL https://raw.githubusercontent.com/milhamh95/nix-config/main/scripts/install.sh | bash
#
# Or download first, then run:
#   curl -fsSL https://raw.githubusercontent.com/milhamh95/nix-config/main/scripts/install.sh -o install.sh
#   bash install.sh
#
# To clone a specific branch:
#   bash install.sh <branch-name>

set -e

REPO_URL="https://github.com/milhamh95/nix-config.git"
BRANCH="${1:-main}"
INSTALL_DIR="$HOME/nix/nix-config"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Nix Config Bootstrap ===${NC}"
echo ""

# Step 1: Install Xcode Command Line Tools
echo -e "${BLUE}Step 1: Checking Xcode Command Line Tools...${NC}"
if ! xcode-select -p &> /dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo ""
    echo "Please wait for Xcode Command Line Tools installation to complete."
    echo "Press any key to continue after installation is done..."
    read -n 1
else
    echo -e "${GREEN}Xcode Command Line Tools already installed ✅${NC}"
fi

# Step 2: Clone the repo
echo ""
echo -e "${BLUE}Step 2: Cloning nix-config...${NC}"
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${GREEN}$INSTALL_DIR already exists, skipping clone ✅${NC}"
else
    mkdir -p "$(dirname "$INSTALL_DIR")"
    git clone -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
    echo -e "${GREEN}Cloned branch '$BRANCH' to $INSTALL_DIR ✅${NC}"
fi

cd "$INSTALL_DIR"

# Step 3: Secrets setup
echo ""
echo -e "${BLUE}Step 3: Secrets setup${NC}"
echo ""
echo "This config uses encrypted secrets (SSH keys, maven settings, etc.)."
echo "You can install with or without secrets."
echo ""
echo "  [1] Install with secrets    (requires age key)"
echo "  [2] Install without secrets (skip secrets, set up later)"
echo ""
read -p "Choose [1/2]: " SECRETS_CHOICE

SKIP_SECRETS=false

if [ "$SECRETS_CHOICE" = "1" ]; then
    AGE_KEY_DEST="$INSTALL_DIR/secrets/age/keys.txt"

    if [ -f "$AGE_KEY_DEST" ]; then
        echo -e "${GREEN}Age key already in place ✅${NC}"
    else
        echo ""
        echo "Save your age key from your password manager to a file on this machine"
        echo "(e.g., ~/Downloads/keys.txt), then enter the path below."
        echo ""
        read -p "Path to age key file: " AGE_KEY_PATH

        # Expand ~ to home directory
        AGE_KEY_PATH="${AGE_KEY_PATH/#\~/$HOME}"

        if [ ! -f "$AGE_KEY_PATH" ]; then
            echo -e "${RED}File not found: $AGE_KEY_PATH${NC}"
            echo "Continuing without secrets."
            SKIP_SECRETS=true
        elif ! grep -q "AGE-SECRET-KEY-1" "$AGE_KEY_PATH"; then
            echo -e "${RED}File does not look like a valid age key${NC}"
            echo "Continuing without secrets."
            SKIP_SECRETS=true
        else
            mkdir -p "$INSTALL_DIR/secrets/age"
            cp "$AGE_KEY_PATH" "$AGE_KEY_DEST"
            chmod 600 "$AGE_KEY_DEST"
            echo -e "${GREEN}Age key installed ✅${NC}"
        fi
    fi
else
    SKIP_SECRETS=true
fi

# Step 4: Choose machine
echo ""
echo -e "${BLUE}Step 4: Select machine to install${NC}"
echo ""
echo "  [1] mac-desktop"
echo "  [2] mbp (personal)"
echo ""
read -p "Choose [1/2]: " MACHINE_CHOICE

if [ "$SKIP_SECRETS" = true ]; then
    case "$MACHINE_CHOICE" in
        1) MAKE_TARGET="install-desktop-nosecrets" ;;
        2) MAKE_TARGET="install-mbp-nosecrets" ;;
        *) echo -e "${RED}Invalid choice${NC}"; exit 1 ;;
    esac
else
    case "$MACHINE_CHOICE" in
        1) MAKE_TARGET="install-desktop" ;;
        2) MAKE_TARGET="install-mbp" ;;
        *) echo -e "${RED}Invalid choice${NC}"; exit 1 ;;
    esac
fi

# Step 5: Run install
echo ""
echo -e "${BLUE}Step 5: Running make $MAKE_TARGET...${NC}"
echo ""

make "$MAKE_TARGET"

# Step 6: Post-install
echo ""
echo -e "${GREEN}=== Installation complete! ===${NC}"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal to use fish shell"
echo "  2. Switch git remote to SSH (after restart):"
echo "     cd $INSTALL_DIR"
echo "     git remote set-url origin git@personal:milhamh95/nix-config.git"

if [ "$SKIP_SECRETS" = true ]; then
    echo ""
    echo -e "${YELLOW}Secrets were skipped.${NC}"
    echo "To enable secrets later:"
    echo "  1. Save your age key to $INSTALL_DIR/secrets/age/keys.txt"
    echo "  2. Run the matching switch command (e.g., make switch)"
fi
