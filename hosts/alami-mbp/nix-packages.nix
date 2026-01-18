# hosts/alami-mbp/nix-packages.nix - Alami MacBook Pro specific system packages
{ config, lib, pkgs, ... }:

{
  # Work-related system packages (same as mac-desktop)
  environment.systemPackages = [
    pkgs.fishPlugins.sdkman-for-fish
    pkgs.sftpgo
    pkgs.zstd
  ];
}
