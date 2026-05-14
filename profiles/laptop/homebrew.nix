# profiles/laptop/homebrew.nix - Shared laptop Homebrew apps
{ config, lib, pkgs, ... }:

{
  homebrew = {
    casks = [
      "batfi"
    ];
  };
}
