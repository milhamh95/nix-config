# The app bundle is shared. Per-host config.json lives on each host's own
# file (modules/hosts/*.nix).
{ inputs, ... }:
{
  den.aspects.kickapp.homeManager.home.file."Applications/KickApp.app" = {
    source = inputs.self + "/dotfiles/kickapp/KickApp.app";
    recursive = true;
  };
}
