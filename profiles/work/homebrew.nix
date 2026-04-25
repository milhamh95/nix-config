# profiles/work/homebrew.nix - Generic work Homebrew apps
{ config, lib, pkgs, ... }:

{
  homebrew = {
    casks = [
      "bloom"
      "tableplus"
    ];
  };
}
