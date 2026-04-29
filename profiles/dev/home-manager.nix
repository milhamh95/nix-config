# profiles/dev/home-manager.nix - Development home-manager config
{ config, pkgs, lib, ... }:

{
  imports = [
    ./fish
    ./mise.nix
  ];

  home.activation = {
    configureMise = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -d "$HOME/.mise" ]; then
        echo "Creating Mise directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.config/mise"
        echo "Mise directory created at $HOME/.config/mise ✅"

        echo "Copying Mise config files..."
        $DRY_RUN_CMD cp ${./dotfiles/mise/config.toml} "$HOME/.config/mise/config.toml"
        echo "Mise configured ✅"

        echo "Installing Mise tools... ⚙️"
        $DRY_RUN_CMD /opt/homebrew/bin/mise install -y
        echo "Mise tools installed ✅"
      fi
    '';
  };

  home.file = {
    ".wezterm.lua" = {
      source = ./dotfiles/wezterm/wezterm.lua;
      onChange = ''
        echo "WezTerm config changed"
      '';
    };
  };

  home.sessionPath = [
    "$HOME/go/bin"
  ];
}
