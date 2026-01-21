# programs/fish-git-alami.nix - Alami git workflow (mac-desktop, alami-mbp only)
{ config, lib, pkgs, ... }:

{
  programs.fish.functions = {
    gca = {
      description = "Git commit for Alami with conventional format and auto Jira ticket";
      body = ''
        # Check if in a git repo
        if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
            echo "Not a git repository"
            return 1
        end

        # Check if there are staged changes
        if test -z (git diff --cached --name-only)
            echo "No staged changes. Run 'git add' first."
            return 1
        end

        # === COMMIT TYPE ===
        echo "Commit type:"
        echo "  1) feat      5) refactor"
        echo "  2) fix       6) test"
        echo "  3) docs      7) chore"
        echo "  4) style     8) perf"
        echo "  0) skip"
        read -P "Select [0-8]: " type_choice

        set -l commit_type ""
        switch $type_choice
            case 1; set commit_type "feat"
            case 2; set commit_type "fix"
            case 3; set commit_type "docs"
            case 4; set commit_type "style"
            case 5; set commit_type "refactor"
            case 6; set commit_type "test"
            case 7; set commit_type "chore"
            case 8; set commit_type "perf"
        end

        # === SCOPE ===
        echo ""
        echo "Scope:"
        echo "  1) BE         4) liquibase"
        echo "  2) FE         5) config"
        echo "  3) FS         6) custom"
        echo "  0) skip"
        read -P "Select [0-6]: " scope_choice

        set -l scope ""
        switch $scope_choice
            case 1; set scope "BE"
            case 2; set scope "FE"
            case 3; set scope "FS"
            case 4; set scope "liquibase"
            case 5; set scope "config"
            case 6
                read -P "Enter custom scope: " scope
        end

        # === JIRA TICKET ===
        # Auto-detect from branch name (P2PL-xxx pattern)
        set -l branch (git branch --show-current)
        set -l auto_jira ""
        if string match -qr 'P2PL-[0-9]+' $branch
            set auto_jira (string match -r 'P2PL-[0-9]+' $branch)
        end

        set -l jira ""
        echo ""
        if test -n "$auto_jira"
            echo "Jira ticket detected: $auto_jira"
            echo "  1) Use $auto_jira"
            echo "  2) Enter custom"
            echo "  0) Skip"
            read -P "Select [0-2]: " jira_choice

            switch $jira_choice
                case 1; set jira $auto_jira
                case 2
                    read -P "Enter Jira ticket: " jira
            end
        else
            echo "No Jira ticket detected from branch"
            echo "  1) Enter Jira ticket"
            echo "  0) Skip"
            read -P "Select [0-1]: " jira_choice

            switch $jira_choice
                case 1
                    read -P "Enter Jira ticket: " jira
            end
        end

        # === COMMIT MESSAGE ===
        echo ""
        read -P "Commit message (required): " message
        if test -z "$message"
            echo "Commit message is required"
            return 1
        end

        # === BUILD COMMIT MESSAGE ===
        set -l full_message ""

        # Add commit type
        if test -n "$commit_type"
            set full_message $commit_type
        end

        # Add scope
        if test -n "$scope"
            if test -n "$full_message"
                set full_message "$full_message($scope)"
            else
                set full_message "($scope)"
            end
        end

        # Add colon after type/scope
        if test -n "$full_message"
            set full_message "$full_message:"
        end

        # Add Jira ticket
        if test -n "$jira"
            set full_message "$full_message [$jira]"
        end

        # Add message
        set full_message "$full_message $message"

        # Trim leading space if no type/scope
        set full_message (string trim $full_message)

        # === CONFIRM WITH FILE CHANGES ===
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Commit: $full_message"
        echo ""
        echo "Files to commit:"
        git diff --cached --stat | sed 's/^/  /'
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        read -P "Push to origin/$branch? (y/n): " confirm

        if test "$confirm" != "y"
            echo "Cancelled"
            return 0
        end

        # Commit and push
        git commit -m "$full_message"
        echo ""
        echo "Pushing to origin/$branch..."
        git push origin $branch

        echo ""
        echo "Done!"
      '';
    };
  };

  programs.fish.shellAbbrs = {
    gca = "gca";  # git commit alami
  };
}
