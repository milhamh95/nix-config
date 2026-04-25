# programs/atuin.nix - Atuin configuration
{ config, lib, pkgs, ... }:

{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      theme = {
        name = "catppuccin-mocha-red";
      };
    };
  };
}
