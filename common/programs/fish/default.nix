# programs/fish/default.nix - Fish shell configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ./functions.nix
    ./abbreviations.nix
  ];

  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "fisher";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fisher";
          rev = "4.4.5";
          sha256 = "sha256-VC8LMjwIvF6oG8ZVtFQvo2mGdyAzQyluAGBoK8N2/QM=";
        };
      }
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
    ];

    shellInit = ''
      set -g fish_greeting

      # Catppuccin Mocha theme for fzf
      set -gx FZF_DEFAULT_OPTS "\
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"
    '';

    interactiveShellInit = ''
      # install catppuccin
      if not test -e $__fish_config_dir/themes/Catppuccin\ Mocha.theme
        fisher install catppuccin/fish
        fish_config theme save "Catppuccin Mocha"
      end

      # remove PatrickF1/fzf.fish if installed (switched to native fzf)
      if functions -q _fzf_search_directory
        fisher remove PatrickF1/fzf.fish 2>/dev/null
      end

      # fzf native shell integration (Alt+C for cd, Ctrl+T for files, Ctrl+R for history)
      if type -q fzf
        fzf --fish | source
      end

      # activate mise
      if type -q mise
        mise activate fish | source
      end
    '';
  };
}
