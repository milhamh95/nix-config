# hosts/mbp/homebrew.nix - MacBook Pro specific Homebrew apps
{ config, lib, pkgs, ... }:

{
  homebrew = {
    # Laptop-specific casks
    casks = [
      "batfi"
      "bruno"
      "conar"
      "mockoon"
      "orbstack"
    ];

    # Laptop-specific Mac App Store apps (add as needed)
    masApps = {
      # Currently none identified as laptop-exclusive
    };
  };
}
