# The work layer. Plugged into a host via `provides.to-users.includes`
# (see modules/hosts/mac-desktop.nix). Delete the plug line to unplug.
{ lib, ... }:
{
  den.aspects.work = {
    darwin = {
      homebrew.casks = [
        "bloom"
        "tableplus"
      ];
      # Prepend Bloom before the common spacer
      system.defaults.dock.persistent-apps = lib.mkBefore [
        { app = "/Applications/Bloom.app"; }
      ];
    };

    homeManager =
      { lib, ... }:
      {
        home.activation.configureWorkFolder = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -d "$HOME/work" ]; then
            echo "Creating Work directory... ⚙️"
            $DRY_RUN_CMD mkdir -p "$HOME/work"
            echo "Work directory created at $HOME/work ✅"
          fi
        '';

        programs.fish.shellAbbrs = {
          work = "cd $HOME/work";
        };
      };
  };
}
