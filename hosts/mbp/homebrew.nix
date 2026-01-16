# hosts/mbp/homebrew.nix - MacBook Pro specific Homebrew apps
{ config, lib, pkgs, ... }:

{
  homebrew = {
    # Laptop-specific casks
    casks = [
      "batfi"
    ];

    # Laptop-specific Mac App Store apps (add as needed)
    masApps = {
      # Currently none identified as laptop-exclusive
    };
  };
}
