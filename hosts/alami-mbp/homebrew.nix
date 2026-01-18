# hosts/alami-mbp/homebrew.nix - Alami MacBook Pro specific Homebrew apps
{ config, lib, pkgs, ... }:

{
  homebrew = {
    # Desktop apps (same as mac-desktop) + laptop apps (batfi, conar)
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
      "batfi"
    ];

    # Mac App Store apps (same as mac-desktop)
    masApps = {
      "Flow" = 1423210932;
      "Numbers" = 409203825;
    };
  };
}
