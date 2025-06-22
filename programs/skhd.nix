# programs/skhd.nix - SKHD configuration
{ config, lib, pkgs, ... }:

{
  # skhd configuration
  services.skhd = {
    enable = true;
    package = pkgs.skhd;
    config = ''
      ctrl + shift + cmd - 9: flashspace profile Personal
      ctrl + shift + cmd - 0: flashspace profile Work 
    '';
  };
}
