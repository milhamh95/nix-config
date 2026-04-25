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
      # "Flow" = 1423210932;
      # "Numbers" = 409203825;
    };
  };
}
