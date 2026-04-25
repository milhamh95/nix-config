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
      "mas"
    ];

    # GUI Apps (shared across all machines)
    casks = [
      "appcleaner"
      "brave-browser"
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
      "obsidian"
      "raycast"
      "rectangle-pro"
      "rocket"
      "shottr"
      "vlc"
      "zoom"
    ];

    masApps = {};

    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };
}
