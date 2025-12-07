# homebrew.nix - Homebrew package configuration
{ config, lib, pkgs, ... }:

# Install app like brave, chrome, etc using homebrew
# So I can easier map application to FlashSpace
# Using nix packages, the app path will be inconsistent each machine
{
  homebrew = {
    enable = true;
    taps = [
      "homebrew/core"
      "homebrew/cask"
      "homebrew/bundle"
    ];
    brews = [
      "claude-code-router"
      "mas"
      "mise"
      "opencode"
    ];
    casks = [
      "antigravity"
      "appcleaner"
      "batfi"
      "betterdisplay"
      "bettermouse"
      "bettertouchtool"
      "bloom"
      "brave-browser"
      "bruno"
      "cap"
      "claude-code"
      "datagrip"
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
      "keka"
      "macupdater"
      "microsoft-edge"
      "mockoon"
      "orbstack"
      "pritunl"
      "raycast"
      "rectangle-pro"
      "rewritebar"
      "setapp"
      "shottr"
      "slack"
      "soundsource"
      "stats"
      "visual-studio-code"
      "vlc"
      "wezterm"
      "windsurf"
      "zed"
      "zoom"
    ];

    masApps = {
      "Amphetamine" = 937984704;
      "BarMarks" = 6739710035;
      "DaisyDisk" = 411643860;
      "ExcalidrawZ" = 6636493997;
      "Fantastical - Calendar" = 975937182;
      "Flow" = 1423210932;
      "iStat Menus" = 6499559693;
      "LilyView" = 529490330;
      "Numbers" = 409203825;
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
