# programs/fish/git-functions.nix - Git-related fzf functions
{ config, lib, pkgs, ... }:

{
  programs.fish.functions = {
    # Shared color-blind friendly delta args (used by preview helpers)
    _cb_delta_args = {
      description = "Shared color-blind friendly delta args (deuteranopia)";
      body = ''
        printf '%s\n' \
          --keep-plus-minus-markers \
          '--minus-style=#cdd6f4 #4a3d1a' \
          '--plus-style=#cdd6f4 #2a4470' \
          '--minus-emph-style=bold #ffffff #6b5a28' \
          '--plus-emph-style=bold #ffffff #2a4a7a' \
          '--line-numbers-minus-style=#f9e2af' \
          '--line-numbers-plus-style=#89b4fa' \
          '--line-numbers-zero-style=#a6adc8'
      '';
    };

    # Preview helpers (called by fzf --preview)
    _fgl_preview = {
      description = "Helper for fgl: preview git show with delta";
      body = ''
        set -l hash $argv[1]
        set -l delta_args (_cb_delta_args)
        git show $hash | delta $delta_args
      '';
    };

    _fgs_preview = {
      description = "Helper for fgs: preview git diff with delta";
      body = ''
        set -l file (echo $argv | string sub -s 4)
        set -l status_code (echo $argv | string sub -l 2)
        set -l delta_args (_cb_delta_args)

        if test "$status_code" = "??"
            bat --color=always --style=numbers "$file"
        else
            git diff HEAD -- "$file" 2>/dev/null | delta $delta_args
            or git diff --cached -- "$file" 2>/dev/null | delta $delta_args
        end
      '';
    };

    _fga_preview = {
      description = "Helper for fga: preview unstaged diff with delta";
      body = ''
        set -l file (echo $argv | string sub -s 4)
        set -l status_code (echo $argv | string sub -l 2)
        set -l delta_args (_cb_delta_args)

        if test "$status_code" = "??"
            bat --color=always --style=numbers "$file"
        else
            git diff -- "$file" 2>/dev/null | delta $delta_args
        end
      '';
    };

    # Interactive git functions
    fgl = {
      description = "Fuzzy search git log with commit preview (using delta, color-blind friendly)";
      body = ''
        if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
            echo "Not a git repository"
            return 1
        end

        set -l header_text "(-) Yellow bg = old/removed line
(+) Blue bg   = new/added line
(-)(+) together = line was modified (old then new)"
        set -l commit (git log --oneline --color=always --format="%C(yellow)%h%Creset %s %C(blue)<%an>%Creset %C(green)(%ar)%Creset" | fzf --ansi --height 60% --header "$header_text" --preview 'fish -c "_fgl_preview {1}"')

        if test -z "$commit"
            return 0
        end

        set -l hash (echo $commit | awk '{print $1}')
        echo $hash
      '';
    };

    fgs = {
      description = "Fuzzy search git status with diff preview";
      body = ''
        if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
            echo "Not a git repository"
            return 1
        end

        set -l header_text "(-) Yellow bg = old/removed line
(+) Blue bg   = new/added line
(-)(+) together = line was modified (old then new)"
        set -l selection (git status --short | fzf --ansi --height 60% --header "$header_text" --preview 'fish -c "_fgs_preview {}"')

        if test -z "$selection"
            return 0
        end

        echo $selection | string sub -s 4
      '';
    };

    fga = {
      description = "Fuzzy git add: interactively stage files with diff preview (multi-select with Tab)";
      body = ''
        if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
            echo "Not a git repository"
            return 1
        end

        # git status --short format: XY filename
        #   X = staging area, Y = working tree
        #   " M" = modified, not staged     "??" = untracked
        #   "MM" = staged then modified      " D" = deleted, not staged
        # Filter: Y (2nd char) is not a space = working tree has changes
        set -l unstaged (git status --short | string match -r -e '^.[^ ]')
        if test -z "$unstaged"
            echo "No unstaged changes to add"
            return 0
        end

        set -l header_text "Status: ?? = untracked, _M = modified, _D = deleted
(-) Yellow bg = old/removed line
(+) Blue bg   = new/added line
Tab to select multiple files, Enter to confirm"
        set -l selections (printf '%s\n' $unstaged | fzf --ansi --multi --height 60% --header "$header_text" --preview 'fish -c "_fga_preview {}"')

        if test -z "$selections"
            return 0
        end

        for selection in $selections
            set -l file (echo $selection | string sub -s 4)
            git add "$file"
        end

        # Show updated status
        echo ""
        echo "Current status:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        set -l status_lines (git status --short)
        for line in $status_lines
            set -l x (echo $line | string sub -l 1)
            set -l y (echo $line | string sub -s 2 -l 1)
            set -l file (echo $line | string sub -s 4)
            if test "$x" != " " -a "$x" != "?"
                set_color 89b4fa
                echo "  [staged]   $x  $file"
                set_color normal
            end
            if test "$y" != " " -a "$y" != "?"
                set_color fab387
                echo "  [unstaged] $y  $file"
                set_color normal
            end
            if test "$x" = "?" -a "$y" = "?"
                set_color cdd6f4
                echo "  [untracked]   $file"
                set_color normal
            end
        end
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      '';
    };

    fgb = {
      description = "Fuzzy switch git branch with commit preview";
      body = ''
        if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
            echo "Not a git repository"
            return 1
        end

        set -l branch
        if test "$argv[1]" = "-a"
            set branch (git branch -a --color=always | grep -v HEAD | fzf --ansi --height 60% --preview "git log --oneline --color=always -20 {1}" | sed 's/^[* ]*//' | sed 's|remotes/origin/||')
        else
            set branch (git branch --color=always | fzf --ansi --height 60% --preview "git log --oneline --color=always -20 {1}" | sed 's/^[* ]*//')
        end

        if test -z "$branch"
            return 0
        end

        git switch $branch
      '';
    };

    fgbd = {
      description = "Fuzzy delete local git branches (multi-select with Tab)";
      body = ''
        if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
            echo "Not a git repository"
            return 1
        end

        set -l current (git branch --show-current)

        set -l branches (git branch --color=always | grep -v "^\*" | fzf --ansi --multi --height 60% --preview "git log --oneline --color=always -20 {1}" --header "Tab to select multiple, Enter to confirm" | sed 's/^[ ]*//')

        if test -z "$branches"
            echo "No branches selected"
            return 0
        end

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

        for branch in $branches
            echo "Deleting $branch..."
            git branch -D $branch
        end

        echo ""
        echo "Done!"
      '';
    };

    fgbdr = {
      description = "Fuzzy delete remote git branches (multi-select with Tab)";
      body = ''
        if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
            echo "Not a git repository"
            return 1
        end

        echo "Fetching remote branches..."
        git fetch --prune

        set -l branches (git branch -r --color=always | grep -v HEAD | grep -v main | grep -v master | fzf --ansi --multi --height 60% --preview "git log --oneline --color=always -20 {1}" --header "Tab to select multiple, Enter to confirm" | sed 's/^[ ]*//' | sed 's|origin/||')

        if test -z "$branches"
            echo "No branches selected"
            return 0
        end

        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Branches to DELETE (remote origin):"
        for branch in $branches
            echo "  - origin/$branch"
        end
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "WARNING: This will delete branches from the remote!"
        read -P "Are you sure? (y/n): " confirm

        if test "$confirm" != "y"
            echo "Cancelled"
            return 0
        end

        for branch in $branches
            echo "Deleting origin/$branch..."
            git push origin --delete $branch
        end

        echo ""
        echo "Done!"
      '';
    };

    fgbc = {
      description = "Fuzzy compare two git branches with delta";
      body = ''
        if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
            echo "Not a git repository"
            return 1
        end

        set -l current (git branch --show-current)

        echo "Select FIRST branch (base):"
        set -l branch1 (git branch -a --color=always | grep -v HEAD | fzf --ansi --height 50% --preview "git log --oneline --color=always -15 {1}" --header "Select BASE branch" --query "$current" | sed 's/^[* ]*//' | sed 's|remotes/origin/||' | string trim)

        if test -z "$branch1"
            echo "No branch selected"
            return 0
        end

        echo ""
        echo "Select SECOND branch (compare):"
        set -l branch2 (git branch -a --color=always | grep -v HEAD | grep -v "$branch1\$" | fzf --ansi --height 50% --preview "git log --oneline --color=always -15 {1}" --header "Select COMPARE branch (comparing against $branch1)" | sed 's/^[* ]*//' | sed 's|remotes/origin/||' | string trim)

        if test -z "$branch2"
            echo "No branch selected"
            return 0
        end

        while true
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Comparing: $branch1 -> $branch2"
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
  };
}
