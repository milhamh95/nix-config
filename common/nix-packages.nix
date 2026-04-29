# common/nix-packages.nix - Shared system packages and fonts configuration
{ config, lib, pkgs, ... }:

{
  # System packages (shared across all machines)
  environment.systemPackages = [
    pkgs.age
    pkgs.atuin
    pkgs.bat
    pkgs.curl
    pkgs.delta
    pkgs.fastfetch
    pkgs.fd
    pkgs.fishPlugins.tide
    pkgs.fishPlugins.sponge
    pkgs.fishPlugins.z
    pkgs.fishPlugins.done
    pkgs.fzf
    pkgs.git
    pkgs.lsd
    pkgs.openssl
    pkgs.sops
    pkgs.vim
    pkgs.wget
  ];

  # Font configuration
  fonts.packages = with pkgs; [
    nerd-fonts.im-writing
    nerd-fonts.hack
    nerd-fonts.blex-mono
    nerd-fonts.jetbrains-mono
  ];
}
