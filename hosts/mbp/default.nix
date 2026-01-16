# hosts/mbp/default.nix - MacBook Pro host configuration
{ config, lib, pkgs, ... }:

{
  # Host-specific system configuration
  networking.hostName = "mbp";
}
