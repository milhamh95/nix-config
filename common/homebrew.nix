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
      "mise"
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
      "Flow" = 1423210932;
    };

    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };
}
