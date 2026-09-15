# Core fish shell setup. Abbreviations, functions, and git functions are
# separate aspects (fish-abbr.nix, fish-functions.nix, fish-git-functions.nix)
# so each concern stays in its own file.
{
  den.aspects.fish.homeManager =
    { pkgs, lib, ... }:
    {
      home.activation.configureTide = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -e "$HOME/.config/fish/tide_configured" ]; then
          echo "Configuring Tide... ⚙️"
          export TERM=xterm-256color
          $DRY_RUN_CMD ${pkgs.fish}/bin/fish -c 'tide configure --auto --style=Rainbow --prompt_colors="True color" --show_time=No --rainbow_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style="Two lines, character and frame" --prompt_connection=Disconnected --powerline_right_prompt_frame=Yes --prompt_connection_andor_frame_color=Lightest --prompt_spacing=Sparse --icons="Many icons" --transient=No'
          $DRY_RUN_CMD touch "$HOME/.config/fish/tide_configured"
          echo "Finish Configuring Tide... ✅"
        fi
      '';

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
          # install catppuccin (skip if SSH key not available yet)
          if not test -e $__fish_config_dir/themes/catppuccin-mocha.theme
            if test -f ~/.ssh/id_github_personal
              fisher install catppuccin/fish
              fish_config theme choose catppuccin-mocha
            end
          end

          # remove PatrickF1/fzf.fish if installed (switched to native fzf)
          if functions -q _fzf_search_directory
            fisher remove PatrickF1/fzf.fish 2>/dev/null
          end

          # fzf native shell integration (Alt+C for cd, Ctrl+T for files, Ctrl+R for history)
          if type -q fzf
            fzf --fish | source
          end
        '';
      };
    };
}
