# hosts/alami-mbp/home-manager.nix - Alami MacBook Pro specific home-manager config
{ config, pkgs, lib, ... }:

{
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
  };

  programs.fish.shellAbbrs = {
    nixalami = "sudo darwin-rebuild switch --flake .#alami-mbp";
  };
}
