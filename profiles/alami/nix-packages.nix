# profiles/alami/nix-packages.nix - Alami work system packages
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.sftpgo
    pkgs.zstd
  ];
}
