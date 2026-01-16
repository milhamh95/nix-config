# hosts/mac-desktop/nix-packages.nix - Mac Desktop specific system packages
{ config, lib, pkgs, ... }:

{
  # Desktop-specific system packages
  environment.systemPackages = [
    pkgs.fishPlugins.sdkman-for-fish
    pkgs.sftpgo
    pkgs.zstd
  ];
}
