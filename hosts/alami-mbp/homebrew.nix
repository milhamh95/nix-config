# hosts/alami-mbp/homebrew.nix - Alami MacBook Pro only Homebrew apps
{ config, lib, pkgs, ... }:

{
  homebrew = {
    casks = [
      "batfi"
    ];

    masApps = {
      "Flow" = 1423210932;
      "Numbers" = 409203825;
    };
  };
}
