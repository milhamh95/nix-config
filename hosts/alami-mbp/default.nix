# hosts/alami-mbp/default.nix - Alami MacBook Pro host configuration
{ config, lib, pkgs, ... }:

{
  # Host-specific system configuration
  networking.hostName = "alami-mbp";
}
