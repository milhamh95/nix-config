# common/homebrew.nix - Shared Homebrew package configuration
{ config, lib, pkgs, ... }:

# Install apps using homebrew for consistent paths across machines
# This makes it easier to map applications to FlashSpace
{
  environment.shellInit = lib.mkIf config.homebrew.enable ''
    eval "$(${config.homebrew.prefix}/bin/brew shellenv)"
  '';

  homebrew = {
    enable = true;
    taps = [];

    # CLI tools (shared across all machines)
    brews = [
      "gh"
      "mas"
      "mole"
    ];

    # GUI Apps (shared across all machines)
    casks = [
      "appcleaner"
      "brave-browser"
      "bruno"
      "cmux"
      "discord"
      "flashspace"
      "ghostty"
      "google-chrome"
      "google-chrome@beta"
      "hammerspoon"
      "homerow"
      "iina"
      "jordanbaird-ice"
      "karabiner-elements"
      "keka"
      "mockoon"
      "obsidian"
      "orbstack"
      "raycast"
      "rectangle-pro"
      "rocket"
      "shottr"
      "visual-studio-code"
      "vlc"
      "wezterm"
      "zoom"
    ];

    masApps = {
      "Amphetamine" = 937984704;
      "BarMarks" = 6739710035;
      "DaisyDisk" = 411643860;
      "ExcalidrawZ" = 6636493997;
      "Fantastical" = 975937182;
      "Flow" = 1423210932;
      "Folder Quick Look" = 6753110395;
      "iStat Menus" = 6499559693;
      "LilyView" = 529490330;
      "Numbers" = 409203825;
      "OpenIn" = 1643649331;
      "PastePal" = 1503446680;
      "PDF Expert" = 1055273043;
      "Presentify" = 1507246666;
      "SnippetsLab" = 1006087419;
      "Spark" = 1176895641;
      "Spokenly" = 6740315592;
    };

    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "zap";
  };
}
