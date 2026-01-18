# hosts/mac-desktop/homebrew.nix - Mac Desktop specific Homebrew apps
{ config, lib, pkgs, ... }:

{
  homebrew = {
    # Desktop-specific casks
    casks = [
      "bettermouse"
      "betterdisplay"
      "bloom"
      "github"
      "google-chrome@beta"
      "pritunl"
      "rewritebar"
      "slack"
      "tableplus"
      "windsurf"
      "wezterm"
      "zed"
    ];

    # Desktop-specific Mac App Store apps
    masApps = {
      "Flow" = 1423210932;
      "Numbers" = 409203825;
    };
  };
}
