# profiles/dev/fish/default.nix - Development fish shell config
{ config, lib, pkgs, ... }:

{
  imports = [
    ../../../common/programs/fish/git-functions.nix
    ./functions.nix
    ./abbreviations.nix
  ];
}
