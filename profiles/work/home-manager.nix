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

  home.file = {
    # Shared Flashspace settings
    ".config/flashspace/settings.json" = {
      source = ./dotfiles/flashspace/settings.json;
      force = true;
      onChange = ''
        echo "Flashspace settings changed"
      '';
    };
    ".config/kickapp/config.json" = {
      source = ./dotfiles/kickapp/config.json;
      force = true;
      onChange = ''
        echo "KickApp config changed"
      '';
    };
  };

  programs.fish.shellAbbrs = {
    work = "cd $HOME/work";
  };
}
