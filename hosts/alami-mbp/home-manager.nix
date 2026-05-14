# hosts/alami-mbp/home-manager.nix - Alami MacBook Pro specific home-manager config
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
  };

  programs.fish.shellAbbrs = {
    nixalami = "sudo darwin-rebuild switch --flake .#alami-mbp";
  };
}
