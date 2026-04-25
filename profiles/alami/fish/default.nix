# profiles/alami/fish/default.nix - Alami fish shell config
{ config, lib, pkgs, ... }:

{
  imports = [
    ./functions.nix
    ./abbreviations.nix
  ];
}
