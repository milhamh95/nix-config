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
      fcd = {
        description = "Fuzzy change directory with preview (lsd for folders, bat for files)";
        body = ''
          # Set search directory (default: current directory)
          if set -q argv[1]
              set searchdir $argv[1]
          else
              set searchdir .
          end

          # Find files and directories, use fzf with conditional preview
          set -l selection (fd --hidden --exclude .git --exclude node_modules --exclude __pycache__ . $searchdir | fzf --height 60% --preview "test -d {} && lsd --color=always --icon=always --group-dirs=first -1 {} || bat --color=always --style=numbers --line-range=:100 {}")

          # If nothing selected, exit
          if test -z "$selection"
              return 0
          end

          # If directory, cd into it. If file, cd into its parent directory
          if test -d "$selection"
              cd $selection
          else
              cd (dirname $selection)
          end
        '';
      };
      fgl = {
        description = "Fuzzy search git log with commit preview (using delta)";
        body = ''
          # Check if in a git repo
          if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
              echo "Not a git repository"
              return 1
          end

          # Show git log with fzf, preview shows commit diff with delta
          set -l commit (git log --oneline --color=always --format="%C(yellow)%h%Creset %s %C(blue)<%an>%Creset %C(green)(%ar)%Creset" | fzf --ansi --height 60% --preview "git show {1} | delta")

          # If nothing selected, exit
          if test -z "$commit"
              return 0
          end

          # Extract commit hash and echo it
          set -l hash (echo $commit | awk '{print $1}')
          echo $hash
        '';
      };
      fgs = {
        description = "Fuzzy search git status with diff preview (using delta)";
        body = ''
          # Check if in a git repo
          if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
              echo "Not a git repository"
              return 1
          end

          # Show git status with fzf, preview shows file diff with delta
          set -l file (git status --short | fzf --ansi --height 60% --preview "git diff {2} | delta")

          # If nothing selected, exit
          if test -z "$file"
              return 0
          end

          # Extract file path and echo it
          echo $file | awk '{print $2}'
        '';
      };
      fgb = {
        description = "Fuzzy switch git branch with commit preview";
        body = ''
          # Check if in a git repo
          if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
              echo "Not a git repository"
              return 1
          end

          # Get branches (local by default, -a flag for all including remote)
          set -l branch
          if test "$argv[1]" = "-a"
              set branch (git branch -a --color=always | grep -v HEAD | fzf --ansi --height 60% --preview "git log --oneline --color=always -20 {1}" | sed 's/^[* ]*//' | sed 's|remotes/origin/||')
          else
              set branch (git branch --color=always | fzf --ansi --height 60% --preview "git log --oneline --color=always -20 {1}" | sed 's/^[* ]*//')
          end

          # If nothing selected, exit
          if test -z "$branch"
              return 0
          end

          # Switch to branch
          git switch $branch
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
      fdc = "fcd";  # fuzzy cd from current directory
      fdh = "fcd $HOME";  # fuzzy cd from home directory
      fgl = "fgl";  # fuzzy git log
      fgs = "fgs";  # fuzzy git status
      fgb = "fgb";  # fuzzy git branch switch
    };
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
