# hosts/mbp/homebrew.nix - MacBook Pro specific Homebrew apps
{ config, lib, pkgs, ... }:

{
  homebrew = {
    # Laptop-specific casks
    casks = [
      "batfi"
    ];

};
}
