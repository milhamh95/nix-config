# hosts/mac-desktop/default.nix - Mac Desktop host configuration
{ config, lib, pkgs, ... }:

{
  # Host-specific system configuration
  networking.hostName = "mac-desktop";
}
