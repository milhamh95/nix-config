{ pkgs }:

pkgs.mkShell {
  packages = with pkgs; [ age sops ];

  shellHook = ''
    # Configuration
    export SOPS_AGE_KEY_DIR="$HOME/Library/Application Support/sops/age"
    export SOPS_AGE_KEY_FILE="$SOPS_AGE_KEY_DIR/keys.txt"

    sops_help() {
      echo "SOPS/Age Development Shell Commands:"
      echo ""
      echo "Age Key Management:"
      echo "  sops_generate_key    - Generate a new age key"
      echo "  sops_show_pubkey     - Show your age public key"
      echo "  sops_key_status      - Check if age key exists"
      echo ""
      echo "SOPS Operations:"
      echo "  sops_encrypt <file>  - Encrypt a file with sops"
      echo "  sops_decrypt <file>  - Decrypt a file with sops"
      echo "  sops_edit <file>     - Edit an encrypted file"
      echo ""
      echo "Key Location: $SOPS_AGE_KEY_FILE"
      echo ""
      echo "Setup Steps:"
      echo "  1. sops_generate_key   # Generate age key"
      echo "  2. sops_show_pubkey    # Copy this to .sops.yaml"
      echo "  3. Backup keys.txt to password manager!"
    }

    sops_generate_key() {
      if [ -f "$SOPS_AGE_KEY_FILE" ]; then
        echo "Age key already exists at: $SOPS_AGE_KEY_FILE"
        echo "To regenerate, first delete the existing key."
        return 1
      fi

      mkdir -p "$SOPS_AGE_KEY_DIR"
      age-keygen -o "$SOPS_AGE_KEY_FILE"
      chmod 600 "$SOPS_AGE_KEY_FILE"

      echo ""
      echo "Age key generated at: $SOPS_AGE_KEY_FILE"
      echo ""
      echo "IMPORTANT: Backup this key to your password manager!"
      echo ""
      sops_show_pubkey
    }

    sops_show_pubkey() {
      if [ ! -f "$SOPS_AGE_KEY_FILE" ]; then
        echo "No age key found. Run 'sops_generate_key' first."
        return 1
      fi

      echo "Your age public key (add this to .sops.yaml):"
      echo ""
      grep "public key:" "$SOPS_AGE_KEY_FILE" | cut -d: -f2 | tr -d ' '
    }

    sops_key_status() {
      if [ -f "$SOPS_AGE_KEY_FILE" ]; then
        echo "Age key exists at: $SOPS_AGE_KEY_FILE"
        echo ""
        sops_show_pubkey
      else
        echo "No age key found."
        echo "Run 'sops_generate_key' to create one."
      fi
    }

    sops_encrypt() {
      if [ -z "$1" ]; then
        echo "Usage: sops_encrypt <file>"
        return 1
      fi
      sops -e -i "$1"
      echo "Encrypted: $1"
    }

    sops_decrypt() {
      if [ -z "$1" ]; then
        echo "Usage: sops_decrypt <file>"
        return 1
      fi
      sops -d "$1"
    }

    sops_edit() {
      if [ -z "$1" ]; then
        echo "Usage: sops_edit <file>"
        return 1
      fi
      sops "$1"
    }

    echo "SOPS/Age Shell (run 'sops_help' for commands)"
    echo ""
    sops_key_status
    echo ""
    echo "Commands: sops_generate_key, sops_show_pubkey, sops_help"
  '';
}
