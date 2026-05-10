# hosts/mac-desktop/home-manager.nix - Mac Desktop specific home-manager config
{ config, pkgs, lib, ... }:

{
  home.activation = {
    installSwitor = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Checking Switor installation..."
      SWITOR_APP="/Applications/Switor.app"
      SOURCE_APP="${./dotfiles/switor/Switor.app}"

      if [ -d "$SWITOR_APP" ]; then
        echo "Switor is already installed ✅"
      else
        echo "Installing Switor to /Applications..."
        $DRY_RUN_CMD cp -R "$SOURCE_APP" /Applications/
        echo "Switor installed successfully ✅"
      fi
    '';
  };

  home.file = {
    # Git config (host-specific)
    ".gitconfig" = {
      source = ./dotfiles/git/.gitconfig;
      onChange = ''
        echo "Git config changed"
      '';
    };
    ".config/flashspace/profiles.json" = {
      source = ./dotfiles/flashspace/profiles.json;
      force = true;
      onChange = ''
        echo "Flashspace profiles changed"
      '';
    };
    ".config/flashspace/settings.json" = {
      source = ./dotfiles/flashspace/settings.json;
      force = true;
      onChange = ''
        echo "Flashspace settings changed"
      '';
    };
    ".hammerspoon/home.toml" = {
      source = ./dotfiles/hammerflow/home.toml;
      onChange = ''
        echo "Hammerspoon home config changed"
      '';
    };
    ".hammerspoon/init.lua" = {
      source = ./dotfiles/hammerflow/init.lua;
      onChange = ''
        echo "Hammerspoon init config changed"
      '';
    };
    ".config/switor/config.json" = {
      source = ./dotfiles/switor/config.json;
      force = true;
      onChange = ''
        echo "Switor config changed"
      '';
    };
  };

  programs.fish.shellAbbrs = {
    nixmd = "sudo darwin-rebuild switch --flake .#mac-desktop";
  };
}
