.PHONY: install-desktop install-mbp install-desktop-nosecrets install-mbp-nosecrets switch-desktop switch-mbp switch-desktop-nosecrets switch-mbp-nosecrets update check clean setup-secrets export-age-key

# First-time installation
install-desktop:
	bash scripts/install-desktop.sh

install-mbp:
	bash scripts/install-mbp.sh

# First-time installation (without secrets)
install-desktop-nosecrets:
	@touch secrets/.skip
	bash scripts/install-desktop.sh
	@rm -f secrets/.skip

install-mbp-nosecrets:
	@touch secrets/.skip
	bash scripts/install-mbp.sh
	@rm -f secrets/.skip

# Daily rebuild (after nix-darwin is installed)
switch-desktop:
	sudo darwin-rebuild switch --flake .#mac-desktop

switch-mbp:
	sudo darwin-rebuild switch --flake .#mbp

# Daily rebuild (without secrets)
switch-desktop-nosecrets:
	@touch secrets/.skip
	sudo darwin-rebuild switch --flake .#mac-desktop
	@rm -f secrets/.skip

switch-mbp-nosecrets:
	@touch secrets/.skip
	sudo darwin-rebuild switch --flake .#mbp
	@rm -f secrets/.skip

# Update flake inputs
update:
	nix flake update

# Check flake configuration
check:
	nix flake check

# Garbage collection
clean:
	nix-collect-garbage -d

# Secrets management
export-age-key:
	@AGE_SRC="$$HOME/Library/Application Support/sops/age/keys.txt"; \
	if [ ! -f "$$AGE_SRC" ]; then \
		echo "⚠️  Age key not found at $$AGE_SRC"; \
		echo "Run 'make setup-secrets' first to generate it."; \
		exit 1; \
	fi; \
	mkdir -p secrets/age; \
	cp "$$AGE_SRC" secrets/age/keys.txt; \
	chmod 600 secrets/age/keys.txt; \
	echo "✅ Age key copied to secrets/age/keys.txt"; \
	echo "   Back this up to your password manager, then delete it from the repo folder."

setup-secrets:
	@echo "Setting up secrets..."
	@echo "1. Put your private key in secrets/raw/id_github_personal"
	@echo "2. This will generate age key, update .sops.yaml, and encrypt"
	@echo ""
	@nix-shell -p age sops --run "bash scripts/setup-secrets.sh"

# Help
help:
	@echo "Nix Darwin Configuration"
	@echo ""
	@echo "First-time installation:"
	@echo "  make install-desktop             - Install for Mac Desktop"
	@echo "  make install-mbp                 - Install for MacBook Pro (personal)"
	@echo "  make install-desktop-nosecrets   - Install without secrets decryption"
	@echo "  make install-mbp-nosecrets       - Install without secrets decryption"
	@echo ""
	@echo "Daily usage:"
	@echo "  make switch-desktop              - Rebuild Mac Desktop config"
	@echo "  make switch-mbp                  - Rebuild MacBook Pro config"
	@echo "  make switch-desktop-nosecrets    - Rebuild without secrets decryption"
	@echo "  make switch-mbp-nosecrets        - Rebuild without secrets decryption"
	@echo ""
	@echo "Maintenance:"
	@echo "  make update           - Update flake inputs"
	@echo "  make check            - Check flake configuration"
	@echo "  make clean            - Garbage collection"
	@echo ""
	@echo "Secrets:"
	@echo "  make setup-secrets    - Setup and encrypt secrets (age key + sops)"
	@echo "  make export-age-key   - Copy age key to secrets/age/ for backup or new machine setup"
