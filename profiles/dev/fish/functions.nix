# profiles/dev/fish/functions.nix - Development git workflow functions
{ config, lib, pkgs, ... }:

{
  programs.fish.functions = {
    current_branch = "git branch --show-current";

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
  };
}
