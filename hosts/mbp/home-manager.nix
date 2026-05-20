# hosts/mbp/home-manager.nix - MacBook Pro specific home-manager config
{ config, pkgs, lib, ... }:

{
  home.file = {
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
    ".config/kickapp/config.json" = {
      source = ./dotfiles/kickapp/config.json;
      force = true;
      onChange = ''
        echo "KickApp config changed"
      '';
    };
  };

  programs.fish.shellAbbrs = {
    nixmbp = "sudo darwin-rebuild switch --flake .#mbp";
  };
}
