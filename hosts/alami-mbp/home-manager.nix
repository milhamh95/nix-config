# hosts/alami-mbp/home-manager.nix - Alami MacBook Pro specific home-manager config
{ config, pkgs, lib, ... }:

{
  home.file = {
    # Git config (host-specific)
    ".gitconfig" = {
      source = ../../dotfiles/hosts/alami-mbp/git/.gitconfig;
      onChange = ''
        echo "Git config changed"
      '';
    };
    ".config/flashspace/profiles.json" = {
      source = ../../dotfiles/hosts/alami-mbp/flashspace/profiles.json;
      force = true;
      onChange = ''
        echo "Flashspace profiles changed"
      '';
    };
    ".config/flashspace/settings.json" = {
      source = ../../dotfiles/hosts/alami-mbp/flashspace/settings.json;
      force = true;
      onChange = ''
        echo "Flashspace settings changed"
      '';
    };
    ".hammerspoon/home.toml" = {
      source = ../../dotfiles/hosts/alami-mbp/hammerflow/home.toml;
      onChange = ''
        echo "Hammerspoon home config changed"
      '';
    };
    ".hammerspoon/init.lua" = {
      source = ../../dotfiles/hosts/alami-mbp/hammerflow/init.lua;
      onChange = ''
        echo "Hammerspoon init config changed"
      '';
    };
  };

  programs.fish.shellAbbrs = {
    nixalami = "sudo darwin-rebuild switch --flake .#alami-mbp";
  };
}
