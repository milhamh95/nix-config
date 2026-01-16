# common/nix-packages.nix - Shared system packages and fonts configuration
{ config, lib, pkgs, ... }:

{
  # System packages (shared across all machines)
  environment.systemPackages = [
    pkgs.atuin
    pkgs.bat
    pkgs.curl
    pkgs.fastfetch
    pkgs.fd
    pkgs.fishPlugins.forgit
    pkgs.fishPlugins.tide
    pkgs.fishPlugins.sponge
    pkgs.fishPlugins.colored-man-pages
    pkgs.fishPlugins.z
    pkgs.fishPlugins.done
    pkgs.fzf
    pkgs.git
    pkgs.lazygit
    pkgs.lsd
    pkgs.openssl
    pkgs.ripgrep
    pkgs.vim
    pkgs.wget
    pkgs.yarn-berry_4
  ];

  # Font configuration
  fonts.packages = with pkgs; [
    nerd-fonts.im-writing
    nerd-fonts.hack
    nerd-fonts.blex-mono
    nerd-fonts.jetbrains-mono
  ];
}
