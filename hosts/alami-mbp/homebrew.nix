# hosts/alami-mbp/homebrew.nix - Alami MacBook Pro only Homebrew apps
{ config, lib, pkgs, ... }:

{
  homebrew = {
    casks = [
      "batfi"
    ];

    masApps = {
      "Numbers" = 409203825;
    };
  };
}
