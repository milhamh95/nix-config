# programs/fish/abbreviations.nix - General shell abbreviations
{ config, lib, pkgs, ... }:

{
  programs.fish.shellAbbrs = {
    # File listing (lsd)
    ls = "lsd --group-dirs=first -1";
    lsaf = "lsd -AF --group-dirs=first -1";
    lsla = "lsd -la";

    # Navigation
    prsl = "cd $HOME/personal";
    fdc = "fcd";
    fdh = "fcd $HOME";

    # Misc
    pch = "echo 123";
    refish = "exec fish";
  };
}
