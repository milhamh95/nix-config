# programs/fish.nix - Fish shell configuration
{ config, lib, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    functions = {
      current_branch = "git branch --show-current";
      mkcd = {
        description = "Create and change directory";
        body = ''
          if test (count $argv) -ne 1
              echo "Usage: mkcd <directory>"
              return 1
          end

          mkdir -p $argv[1] && cd $argv[1]
        '';
      };
    };
    plugins = [
      {
        name = "fisher";
          src = pkgs.fetchFromGitHub {
            owner = "jorgebucaran";
            repo = "fisher";
            rev = "4.4.5";
            sha256 = "sha256-VC8LMjwIvF6oG8ZVtFQvo2mGdyAzQyluAGBoK8N2/QM=";  # Replace with the correct hash
          };
      }
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
    ];

    shellAbbrs = {
      vc = "open $1 -a \"Visual Studio Code\"";
      ws = "open $1 -a \"Windsurf\"";
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gs = "git status";
      gpo = "git push origin";
      gpof = "git push --force-with-lease origin";
      gpoc = "git push origin (current_branch)";
      gpofc = "git push --force-with-lease origin (current_branch)";
      gplro = "git pull --rebase origin (current_branch)";
      gco = "git checkout";
      gcob = "git checkout -b";
      gcmv = "git commit -v";
      gcmm = "git commit -m";
      gss = "git status -s";
      gbd = "git branch -D";
      gbod = "git push origin -d";
      gl = "git log --color --pretty=format:'%Cred%h%Creset - %s %Cgreen(%ad) %C(bold blue)<%an - %C(yellow)%ae>% %Creset' --abbrev-commit --date=format:'%Y-%m-%d %H:%M:%S'";
      gls = "git log --color --all --date-order --decorate --dirstat=lines,cumulative --stat | sed 's/\\([0-9] file[s]\\? changed\\)/\\1\\n_______\\n-------/g' | less -R";
      pch = "echo 123";
      ls = "lsd --group-dirs=first -1";
      lsaf = "lsd -AF --group-dirs=first -1";
      lsla = "lsd -la";
      prsl = "cd $HOME/personal";
    };
    shellInit = ''
      set -g fish_greeting
    '';
    interactiveShellInit = ''
      # install catppuccin
      if not test -e $__fish_config_dir/themes/Catppuccin\ Mocha.theme
        fisher install catppuccin/fish
        fish_config theme save "Catppuccin Mocha"
      end

      # activate mise
      if type -q mise
        mise activate fish | source
      end
    '';
  };
}
