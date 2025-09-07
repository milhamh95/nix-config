# packages.nix - System packages and fonts configuration
{ config, lib, pkgs, ... }:

{
  # System packages
  environment.systemPackages = [
    pkgs.atuin
    pkgs.bat
    pkgs.claude-code
    pkgs.fastfetch
    pkgs.fd
    pkgs.fishPlugins.forgit
    pkgs.fishPlugins.tide
    pkgs.fishPlugins.sponge
    pkgs.fishPlugins.sdkman-for-fish
    pkgs.fishPlugins.colored-man-pages
    pkgs.fishPlugins.z
    pkgs.fishPlugins.done
    pkgs.fzf
    pkgs.git
    pkgs.lazygit
    pkgs.lsd
    pkgs.mise
    pkgs.openssl
    pkgs.ripgrep
    pkgs.sftpgo
    pkgs.uv
    pkgs.vim
    pkgs.wget
    pkgs.wifi-password
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
