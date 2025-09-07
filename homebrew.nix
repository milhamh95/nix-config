# homebrew.nix - Homebrew package configuration
{ config, lib, pkgs, ... }:

{
  homebrew = {
    enable = true;
    taps = [
      "homebrew/core"
      "homebrew/cask"
      "homebrew/bundle"
    ];
    brews = [
      "mas"
      "mise"
    ];
    casks = [
      "appcleaner"
      "batfi"
      "betterdisplay"
      "bettermouse"
      "brave-browser"
      "bruno"
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
      "macupdater"
      "microsoft-edge"
      "mockoon"
      "orbstack"
      "pritunl"
      "raycast"
      "rectangle-pro"
      "setapp"
      "slack"
      "soundsource"
      "visual-studio-code"
      "vlc"
      "wezterm"
      "windsurf"
      "zoom"
    ];

    masApps = {
      "Amphetamine" = 937984704;
      "DaisyDisk" = 411643860;
      "ExcalidrawZ" = 6636493997;
      "Fantastical - Calendar" = 975937182;
      "LilyView" = 529490330;
      "Numbers" = 409203825;
      "PDF Expert – Edit, Sign PDFs" = 1055273043;
      "rcmd • App Switcher" = 1596283165;
      "Spark Classic – Email App" = 1176895641;
    };

    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };
}
