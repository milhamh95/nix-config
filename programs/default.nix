# programs/default.nix - Import all program modules
{ config, lib, pkgs, ... }:

{
  imports = [
    ./atuin.nix
    ./fastfetch.nix
    ./fish.nix
    ./skhd.nix
  ];
}
