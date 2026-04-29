# hosts/mac-desktop/homebrew.nix - Mac Desktop only Homebrew apps
{ config, lib, pkgs, ... }:

{
  homebrew = {
    casks = [
      "bettermouse"
      "bettertouchtool"
      "betterdisplay"
    ];

    masApps = {
      "Numbers" = 409203825;
    };
  };
}
