# profiles/dev/homebrew.nix - Development Homebrew packages
{ config, lib, pkgs, ... }:

{
  homebrew = {
    brews = [
      "gh"
      "mise"
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
