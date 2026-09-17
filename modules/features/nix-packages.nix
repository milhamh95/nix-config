{ inputs, ... }:
{
  den.aspects.nix-packages.darwin =
    { pkgs, ... }:
    {
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

      fonts.packages = with pkgs; [
        nerd-fonts.im-writing
        nerd-fonts.hack
        nerd-fonts.blex-mono
        nerd-fonts.jetbrains-mono
      ];
    };
}
