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
    pkgs.fishPlugins.forgit
    pkgs.fishPlugins.colored-man-pages
    pkgs.fishPlugins.sdkman-for-fish
    pkgs.fzf
    pkgs.git
    pkgs.lazygit
    pkgs.lsd
    pkgs.openssl
    pkgs.sops
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
