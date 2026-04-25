# profiles/alami/fish/abbreviations.nix - Alami shell abbreviations
{ config, lib, pkgs, ... }:

{
  programs.fish.shellAbbrs = {
    ws = "open $1 -a \"Windsurf\"";
  };
}
