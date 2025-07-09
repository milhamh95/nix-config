# homebrew.nix - Homebrew package configuration
{ config, lib, pkgs, ... }:

{
  homebrew = {
    enable = true;
    brews = [
      "helix"
      "mas"
    ];
    casks = [
      "alt-tab"
      "appcleaner"
      "batfi"
      "betterdisplay"
      "bettermouse"
      "brave-browser"
      "discord"
      "dotnet-sdk"
      "flashspace"
      "floorp"
      "github"
      "ghostty"
      "google-chrome"
      "google-chrome@beta"
      "hammerspoon"
      "heptabase"
      "homerow"
      "iina"
      "jordanbaird-ice"
      "karabiner-elements"
      "logitune"
      "macupdater"
      "microsoft-edge"
      "mockoon"
      "orbstack"
      "postman"
      "postman@canary"
      "pritunl"
      "raycast"
      "rectangle-pro"
      "setapp"
      "slack"
      "visual-studio-code"
      "vlc"
      "wezterm"
      "windsurf"
      "zoom"
    ];

    masApps = {
      "Amphetamine" = 937984704;
      "DaisyDisk" = 411643860;
      "Fantastical - Calendar" = 975937182;
      "LilyView" = 529490330;
      "PDF Expert – Edit, Sign PDFs" = 1055273043;
      "rcmd • App Switcher" = 1596283165;
      "Spark Classic – Email App" = 1176895641;
    };

    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };
}
