# packages.nix - System packages and fonts configuration
{ config, lib, pkgs, ... }:

{
  # System packages
  environment.systemPackages = [
    pkgs.atuin
    pkgs.bat
    pkgs.bruno
    pkgs.bun
    pkgs.claude-code
    pkgs.deno
    pkgs.discord
    pkgs.fastfetch
    pkgs.fishPlugins.forgit
    pkgs.fishPlugins.tide
    pkgs.fishPlugins.sponge
    pkgs.fishPlugins.sdkman-for-fish
    pkgs.fishPlugins.colored-man-pages
    pkgs.fishPlugins.z
    pkgs.fishPlugins.done
    pkgs.floorp
    pkgs.fzf
    pkgs.go
    pkgs.git
    pkgs.iina
    pkgs.lazygit
    pkgs.lsd
    pkgs.nodejs_22
    pkgs.pnpm
    pkgs.ripgrep
    pkgs.sftpgo
    pkgs.slack
    pkgs.uv
    pkgs.vim
    pkgs.wezterm
    pkgs.wget
    pkgs.wifi-password
    pkgs.yarn-berry_4
    pkgs.zoom-us
  ];

  # Font configuration
  fonts.packages = with pkgs; [
    nerd-fonts.im-writing
    nerd-fonts.hack
    nerd-fonts.blex-mono
    nerd-fonts.jetbrains-mono
  ];
}
