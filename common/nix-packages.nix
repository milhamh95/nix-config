# common/nix-packages.nix - Shared system packages and fonts configuration
{ config, lib, pkgs, inputs, ... }:

{
  # Garbage collect old generations weekly, keep the store optimised
  nix.gc = {
    automatic = true;
    interval = { Weekday = 5; Hour = 12; Minute = 0; };
    options = "--delete-older-than 30d";
  };

  nix.optimise.automatic = true;

  # System packages (shared across all machines)
  environment.systemPackages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
    pkgs.age
    pkgs.coreutils
    pkgs.curl
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
