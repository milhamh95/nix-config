# packages.nix - System packages and fonts configuration
{ config, lib, pkgs, ... }:

{
  # System packages
  environment.systemPackages = [
    pkgs.atuin
    pkgs.bat
    pkgs.bun
    pkgs.claude-code
    pkgs.deno
    pkgs.fastfetch
    pkgs.fzf
    pkgs.fishPlugins.forgit
    pkgs.fishPlugins.tide
    pkgs.fishPlugins.sponge
    pkgs.fishPlugins.sdkman-for-fish
    pkgs.fishPlugins.colored-man-pages
    pkgs.fishPlugins.z
    pkgs.fishPlugins.done
    pkgs.go
    pkgs.git
    pkgs.lazygit
    pkgs.lsd
    pkgs.nodejs_22
    pkgs.pnpm
    pkgs.ripgrep
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
