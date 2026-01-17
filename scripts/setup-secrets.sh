#!/bin/bash
# Setup and encrypt secrets - single script for everything
#
# Usage:
#   1. Put your private key in secrets/raw/id_github_personal
#   2. Run: ./scripts/setup-secrets.sh
#
# This script will:
#   - Generate age key (if not exists)
#   - Update .sops.yaml with your public key
#   - Encrypt all files in secrets/raw/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SECRETS_DIR="$REPO_DIR/secrets"
RAW_DIR="$SECRETS_DIR/raw"
SOPS_YAML="$REPO_DIR/.sops.yaml"

# macOS age key location
AGE_KEY_DIR="$HOME/Library/Application Support/sops/age"
AGE_KEY_FILE="$AGE_KEY_DIR/keys.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Secrets Setup ===${NC}"
echo ""

# Step 1: Check if raw secrets exist
echo -e "${BLUE}[1/4] Checking for raw secrets...${NC}"
raw_files=$(find "$RAW_DIR" -type f ! -name ".gitkeep" 2>/dev/null | wc -l | tr -d ' ')

if [ "$raw_files" -eq 0 ]; then
    echo -e "${RED}Error: No files found in secrets/raw/${NC}"
    echo ""
    echo "Please put your private key there first:"
    echo "  cp ~/.ssh/id_github_personal secrets/raw/id_github_personal"
    exit 1
fi

echo -e "${GREEN}Found $raw_files file(s) to encrypt${NC}"
echo ""

# Step 2: Generate age key if not exists
echo -e "${BLUE}[2/4] Checking age key...${NC}"

if [ -f "$AGE_KEY_FILE" ]; then
    echo -e "${GREEN}Age key already exists${NC}"
else
    echo "Generating new age key..."
    mkdir -p "$AGE_KEY_DIR"
    age-keygen -o "$AGE_KEY_FILE" 2>&1
    chmod 600 "$AGE_KEY_FILE"
    echo -e "${GREEN}Age key generated at: $AGE_KEY_FILE${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT: Backup this key to your password manager!${NC}"
    echo -e "${YELLOW}Location: $AGE_KEY_FILE${NC}"
fi

# Extract public key
AGE_PUBLIC_KEY=$(grep "public key:" "$AGE_KEY_FILE" | cut -d: -f2 | tr -d ' ')
echo "Public key: $AGE_PUBLIC_KEY"
echo ""

# Step 3: Update .sops.yaml with actual public key
echo -e "${BLUE}[3/4] Updating .sops.yaml...${NC}"

cat > "$SOPS_YAML" << EOF
keys:
  - &user_age $AGE_PUBLIC_KEY

creation_rules:
  - path_regex: secrets/raw/.*
    key_groups:
      - age:
          - *user_age
EOF

echo -e "${GREEN}.sops.yaml updated with your public key${NC}"
echo ""

# Step 4: Encrypt secrets
echo -e "${BLUE}[4/4] Encrypting secrets...${NC}"
echo ""

encrypted_count=0
skipped_count=0

for raw_file in "$RAW_DIR"/*; do
    [ -f "$raw_file" ] || continue
    [ "$(basename "$raw_file")" != ".gitkeep" ] || continue

    filename=$(basename "$raw_file")
    enc_file="$SECRETS_DIR/${filename}.enc"

    if [ -f "$enc_file" ]; then
        echo -e "${YELLOW}[SKIP]${NC} $filename - already encrypted"
        ((skipped_count++))
    else
        echo -e "${GREEN}[ENCRYPT]${NC} $filename -> ${filename}.enc"
        sops --encrypt "$raw_file" > "$enc_file"
        ((encrypted_count++))
    fi
done

echo ""
echo -e "${GREEN}=== Done! ===${NC}"
echo "Encrypted: $encrypted_count, Skipped: $skipped_count"
echo ""

if [ $encrypted_count -gt 0 ]; then
    echo "Next steps:"
    echo "  1. git add secrets/*.enc .sops.yaml"
    echo "  2. git commit -m 'Add encrypted secrets'"
    echo "  3. Run darwin-rebuild to set up sops-nix decryption"
fi

echo ""
echo -e "${YELLOW}Remember: Backup your age key!${NC}"
echo "Location: $AGE_KEY_FILE"
