# profiles/work/home-manager.nix - Generic work home-manager config
{ config, pkgs, lib, ... }:

{
  home.activation = {
    configureWorkFolder = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -d "$HOME/work" ]; then
        echo "Creating Work directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/work"
        echo "Work directory created at $HOME/work ✅"
      fi
    '';
  };

  programs.fish.shellAbbrs = {
    work = "cd $HOME/work";
  };
}
