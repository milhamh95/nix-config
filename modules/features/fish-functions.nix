{
  den.aspects.fish-functions.homeManager.programs.fish.functions = {
    current_branch = "git branch --show-current";

    gclone = {
      description = "Clone a repo, picking personal or a company profile (company list comes from ~/.ssh/config Host aliases, so plugging/unplugging a company aspect adds/removes it here automatically)";
      body = ''
        if test (count $argv) -lt 1
            echo "Usage: gclone <git@github.com:user/repo.git> [personal|<company-alias>]"
            return 1
        end

        set -l url $argv[1]
        set -l profile $argv[2]

        if test -z "$profile"
            set -l companies
            for host in (string match -rg '^Host\s+(\S+)$' <$HOME/.ssh/config)
                if test "$host" != "*" -a "$host" != github.com
                    set -a companies $host
                end
            end
            set profile (printf '%s\n' personal $companies | fzf --height 20% --header "Pick git profile")
        end

        if test -z "$profile"
            echo "No profile selected"
            return 1
        end

        set -l base_dir
        set -l clone_url $url
        if test "$profile" = personal
            set base_dir "$HOME/personal"
        else
            set base_dir "$HOME/work/$profile"
            set clone_url (string replace "github.com" "$profile" $url)
        end

        set -l repo_name (basename $url .git)
        mkdir -p $base_dir
        echo "Cloning into $base_dir/$repo_name (profile: $profile)..."
        git clone $clone_url $base_dir/$repo_name; and cd $base_dir/$repo_name
      '';
    };

    gsync = {
      description = "Fetch and reset current branch to match remote (no rebase, no conflicts)";
      body = ''
        set -l branch (current_branch)
        if test -z "$branch"
            echo "Not on any branch"
            return 1
        end
        echo "Fetching origin..."
        git fetch origin
        echo "Resetting to origin/$branch..."
        git reset --hard origin/$branch
        echo "Done! Local $branch now matches remote."
      '';
    };

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
