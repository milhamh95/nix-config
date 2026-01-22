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
          # Using {2..} to capture full filename (handles spaces in filenames)
          # Using -- to separate paths from revisions
          set -l selection (git status --short | fzf --ansi --height 60% --preview 'git diff -- {2..} 2>/dev/null | delta')

          # If nothing selected, exit
          if test -z "$selection"
              return 0
          end

          # Extract file path (everything after the 3-char status prefix "XY ")
          echo $selection | string sub -s 4
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
      fgbd = {
        description = "Fuzzy delete local git branches (multi-select with Tab)";
        body = ''
          # Check if in a git repo
          if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
              echo "Not a git repository"
              return 1
          end

          # Get current branch to exclude it
          set -l current (git branch --show-current)

          # Select branches to delete (multi-select with Tab)
          set -l branches (git branch --color=always | grep -v "^\*" | fzf --ansi --multi --height 60% --preview "git log --oneline --color=always -20 {1}" --header "Tab to select multiple, Enter to confirm" | sed 's/^[ ]*//')

          # If nothing selected, exit
          if test -z "$branches"
              echo "No branches selected"
              return 0
          end

          # Show confirmation
          echo ""
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo "Branches to DELETE (local):"
          for branch in $branches
              echo "  - $branch"
          end
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo ""
          read -P "Are you sure you want to delete these branches? (y/n): " confirm

          if test "$confirm" != "y"
              echo "Cancelled"
              return 0
          end

          # Delete branches
          for branch in $branches
              echo "Deleting $branch..."
              git branch -D $branch
          end

          echo ""
          echo "Done!"
        '';
      };
      fkill = {
        description = "Fuzzy kill process (multi-select with Tab)";
        body = ''
          # Get only current user's processes (like Activity Monitor)
          # Format: PID, CPU%, MEM%, process name
          set -l pids (ps -u $USER -o pid,pcpu,pmem,comm | sed 1d | sort -k2 -r | fzf --multi --height 60% --header "PID   CPU%  MEM%  COMMAND | Tab to select, Enter to confirm" | awk '{print $1}')

          # If nothing selected, exit
          if test -z "$pids"
              echo "No process selected"
              return 0
          end

          # Show confirmation
          echo ""
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo "Processes to KILL:"
          for pid in $pids
              set -l proc_info (ps -p $pid -o pid=,comm= 2>/dev/null)
              if test -n "$proc_info"
                  echo "  - $proc_info"
              else
                  echo "  - PID $pid"
              end
          end
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo ""
          read -P "Kill these processes? (y/n): " confirm

          if test "$confirm" != "y"
              echo "Cancelled"
              return 0
          end

          # Kill processes
          for pid in $pids
              echo "Killing PID $pid..."
              kill -9 $pid 2>/dev/null
              if test $status -eq 0
                  echo "  Killed"
              else
                  echo "  Failed (may need sudo)"
              end
          end

          echo ""
          echo "Done!"
        '';
      };
      fgbc = {
        description = "Fuzzy compare two git branches with delta";
        body = ''
          # Check if in a git repo
          if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
              echo "Not a git repository"
              return 1
          end

          # Get current branch as default for first selection
          set -l current (git branch --show-current)

          # Select first branch
          echo "Select FIRST branch (base):"
          set -l branch1 (git branch -a --color=always | grep -v HEAD | fzf --ansi --height 50% --preview "git log --oneline --color=always -15 {1}" --header "Select BASE branch" --query "$current" | sed 's/^[* ]*//' | sed 's|remotes/origin/||' | string trim)

          if test -z "$branch1"
              echo "No branch selected"
              return 0
          end

          # Select second branch
          echo ""
          echo "Select SECOND branch (compare):"
          set -l branch2 (git branch -a --color=always | grep -v HEAD | grep -v "$branch1\$" | fzf --ansi --height 50% --preview "git log --oneline --color=always -15 {1}" --header "Select COMPARE branch (comparing against $branch1)" | sed 's/^[* ]*//' | sed 's|remotes/origin/||' | string trim)

          if test -z "$branch2"
              echo "No branch selected"
              return 0
          end

          # Show comparison options in a loop
          while true
              echo ""
              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
              echo "Comparing: $branch1 → $branch2"
              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
              echo ""
              echo "View options:"
              echo "  1) File list only (stat)"
              echo "  2) Full diff with delta"
              echo "  3) Commits between branches"
              echo "  0) Exit"
              read -P "Select [0-3]: " view_choice

              switch $view_choice
                  case 1
                      echo ""
                      git diff --stat $branch1..$branch2
                  case 2
                      echo ""
                      git diff $branch1..$branch2 | delta
                  case 3
                      echo ""
                      echo "Commits in $branch2 not in $branch1:"
                      git log --oneline --color=always $branch1..$branch2
                  case 0
                      echo "Done"
                      return 0
                  case '*'
                      echo "Invalid option"
              end
          end
        '';
      };
      fgbdr = {
        description = "Fuzzy delete remote git branches (multi-select with Tab)";
        body = ''
          # Check if in a git repo
          if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
              echo "Not a git repository"
              return 1
          end

          # Fetch latest remote info
          echo "Fetching remote branches..."
          git fetch --prune

          # Select remote branches to delete (multi-select with Tab)
          set -l branches (git branch -r --color=always | grep -v HEAD | grep -v main | grep -v master | fzf --ansi --multi --height 60% --preview "git log --oneline --color=always -20 {1}" --header "Tab to select multiple, Enter to confirm" | sed 's/^[ ]*//' | sed 's|origin/||')

          # If nothing selected, exit
          if test -z "$branches"
              echo "No branches selected"
              return 0
          end

          # Show confirmation
          echo ""
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo "Branches to DELETE (remote origin):"
          for branch in $branches
              echo "  - origin/$branch"
          end
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo ""
          echo "⚠️  WARNING: This will delete branches from the remote!"
          read -P "Are you sure? (y/n): " confirm

          if test "$confirm" != "y"
              echo "Cancelled"
              return 0
          end

          # Delete remote branches
          for branch in $branches
              echo "Deleting origin/$branch..."
              git push origin --delete $branch
          end

          echo ""
          echo "Done!"
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
      fgbd = "fgbd";  # fuzzy git branch delete (local)
      fgbdr = "fgbdr";  # fuzzy git branch delete (remote)
      fgbc = "fgbc";  # fuzzy git branch compare
      fkill = "fkill";  # fuzzy kill process
      refish = "exec fish";  # reload fish shell
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
