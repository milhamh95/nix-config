# hosts/mbp/homebrew.nix - MacBook Pro specific Homebrew apps
{ config, lib, pkgs, ... }:

{
  homebrew = {
    casks = [
      "batfi"
    ];
  };
}
