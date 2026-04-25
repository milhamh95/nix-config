# programs/fish/functions.nix - General utility functions
{ config, lib, pkgs, ... }:

{
  programs.fish.functions = {
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
        if set -q argv[1]
            set searchdir $argv[1]
        else
            set searchdir .
        end

        set -l selection (fd --hidden --exclude .git --exclude node_modules --exclude __pycache__ . $searchdir | fzf --height 60% --preview "test -d {} && lsd --color=always --icon=always --group-dirs=first -1 {} || bat --color=always --style=numbers --line-range=:100 {}")

        if test -z "$selection"
            return 0
        end

        if test -d "$selection"
            cd $selection
        else
            cd (dirname $selection)
        end
      '';
    };

    fkill = {
      description = "Fuzzy kill process (multi-select with Tab)";
      body = ''
        set -l pids (ps -u $USER -o pid,pcpu,pmem,comm | sed 1d | sort -k2 -r | fzf --multi --height 60% --header "PID   CPU%  MEM%  COMMAND | Tab to select, Enter to confirm" | awk '{print $1}')

        if test -z "$pids"
            echo "No process selected"
            return 0
        end

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
  };
}
