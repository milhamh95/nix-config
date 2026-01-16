# common/homebrew.nix - Shared Homebrew package configuration
{ config, lib, pkgs, ... }:

# Install apps using homebrew for consistent paths across machines
# This makes it easier to map applications to FlashSpace
{
  homebrew = {
    enable = true;
    taps = [
      "homebrew/core"
      "homebrew/cask"
      "homebrew/bundle"
    ];

    # CLI tools (shared across all machines)
    brews = [
      "mas"
      "mise"
      "mole"
      "opencode"
    ];

    # GUI Apps (shared across all machines)
    casks = [
      "antigravity"
      "appcleaner"
      "bettertouchtool"
      "bloom"
      "brave-browser"
      "cap"
      "claude-code"
      "discord"
      "flashspace"
      "ghostty"
      "google-chrome"
      "hammerspoon"
      "heptabase"
      "homerow"
      "iina"
      "jordanbaird-ice"
      "karabiner-elements"
      "keka"
      "raycast"
      "rectangle-pro"
      "rocket"
      "shottr"
      "visual-studio-code"
      "vlc"
      "zoom"
    ];

    # Mac App Store apps (shared across all machines)
    masApps = {
      "Amphetamine" = 937984704;
      "BarMarks" = 6739710035;
      "DaisyDisk" = 411643860;
      "ExcalidrawZ" = 6636493997;
      "Fantastical - Calendar" = 975937182;
      "iStat Menus" = 6499559693;
      "LilyView" = 529490330;
      "OpenIn" = 1643649331;
      "PastePal" = 1503446680;
      "PDF Expert – Edit, Sign PDFs" = 1055273043;
      "Presentify" = 1507246666; 
      "rcmd • App Switcher" = 1596283165;
      "SnippetsLab" = 1006087419;
      "Spark Classic – Email App" = 1176895641;
      "Spokenly" = 6740315592; 
    };

    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };
}
