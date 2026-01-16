.PHONY: install-desktop install-mbp switch-desktop switch-mbp update check clean

# First-time installation
install-desktop:
	bash scripts/install-desktop.sh

install-mbp:
	bash scripts/install-mbp.sh

# Daily rebuild (after nix-darwin is installed)
switch-desktop:
	sudo darwin-rebuild switch --flake .#mac-desktop

switch-mbp:
	sudo darwin-rebuild switch --flake .#mbp

# Update flake inputs
update:
	nix flake update

# Check flake configuration
check:
	nix flake check

# Garbage collection
clean:
	nix-collect-garbage -d

# Help
help:
	@echo "Nix Darwin Configuration"
	@echo ""
	@echo "First-time installation:"
	@echo "  make install-desktop  - Install for Mac Desktop"
	@echo "  make install-mbp      - Install for MacBook Pro"
	@echo ""
	@echo "Daily usage:"
	@echo "  make switch-desktop   - Rebuild Mac Desktop config"
	@echo "  make switch-mbp       - Rebuild MacBook Pro config"
	@echo ""
	@echo "Maintenance:"
	@echo "  make update           - Update flake inputs"
	@echo "  make check            - Check flake configuration"
	@echo "  make clean            - Garbage collection"
