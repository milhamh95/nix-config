# profiles/dev/homebrew.nix - Development Homebrew packages
{ config, lib, pkgs, ... }:

{
  homebrew = {
    brews = [
      "gh"
      "mise"
      "mole"
      "rtk"
    ];

    casks = [
      "bruno"
      "cmux"
      "mockoon"
      "orbstack"
      "visual-studio-code"
    ];
  };
}
