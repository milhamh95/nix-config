# homebrew.nix - Complete Homebrew configuration for nix-darwin
{ homebrew-core, homebrew-cask, homebrew-bundle, nix-homebrew, ... }:

[
  # nix-homebrew module configuration
  nix-homebrew.darwinModules.nix-homebrew
  {
    nix-homebrew = {
      enable = true;
      user = "milhamh95";
      taps = {
        "homebrew/homebrew-core" = homebrew-core;
        "homebrew/homebrew-cask" = homebrew-cask;
        "homebrew/homebrew-bundle" = homebrew-bundle;
      };
      autoMigrate = true;
    };
  }

  # Homebrew package configuration
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
        "elgato-stream-deck"
        "flashspace"
        "floorp"
        "github"
        "ghostty"
        "google-chrome"
        "hammerspoon"
        "heptabase"
        "homerow"
        "iina"
        "jordanbaird-ice"
        "karabiner-elements"
        "logitune"
        "macupdater"
        "microsoft-edge"
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
]
