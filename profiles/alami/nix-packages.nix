# profiles/alami/nix-packages.nix - Alami work system packages
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.fishPlugins.sdkman-for-fish
    pkgs.sftpgo
    pkgs.zstd
  ];
}
