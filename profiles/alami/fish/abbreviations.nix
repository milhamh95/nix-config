# profiles/alami/fish/abbreviations.nix - Alami shell abbreviations
{ config, lib, pkgs, ... }:

{
  programs.fish.shellAbbrs = {
    dv = "open $1 -a \"Devin\"";
  };
}
