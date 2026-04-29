# profiles/dev/nix-packages.nix - Development system packages
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.lazygit
    pkgs.ripgrep
    pkgs.yarn-berry_4

    # Fish plugins for dev workflow
    pkgs.fishPlugins.forgit
    pkgs.fishPlugins.colored-man-pages
  ];
}
