.PHONY: install-desktop install-mbp install-alami switch-desktop switch-mbp switch-alami update check clean setup-secrets export-age-key

# First-time installation
install-desktop:
	bash scripts/install-desktop.sh

install-mbp:
	bash scripts/install-mbp.sh

install-alami:
	bash scripts/install-alami.sh

# Daily rebuild (after nix-darwin is installed)
switch-desktop:
	sudo darwin-rebuild switch --flake .#mac-desktop

switch-mbp:
	sudo darwin-rebuild switch --flake .#mbp

switch-alami:
	sudo darwin-rebuild switch --flake .#alami-mbp

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
	@echo "  make install-desktop  - Install for Mac Desktop"
	@echo "  make install-mbp      - Install for MacBook Pro (personal)"
	@echo "  make install-alami    - Install for Alami MacBook Pro (work)"
	@echo ""
	@echo "Daily usage:"
	@echo "  make switch-desktop   - Rebuild Mac Desktop config"
	@echo "  make switch-mbp       - Rebuild MacBook Pro config"
	@echo "  make switch-alami     - Rebuild Alami MacBook Pro config"
	@echo ""
	@echo "Maintenance:"
	@echo "  make update           - Update flake inputs"
	@echo "  make check            - Check flake configuration"
	@echo "  make clean            - Garbage collection"
	@echo ""
	@echo "Secrets:"
	@echo "  make setup-secrets    - Setup and encrypt secrets (age key + sops)"
	@echo "  make export-age-key   - Copy age key to secrets/age/ for backup or new machine setup"
