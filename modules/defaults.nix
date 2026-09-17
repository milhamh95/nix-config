# den.default applies to ALL hosts, users, and homes — global settings only.
{ den, ... }:
{
  den.default.darwin = {
    system.stateVersion = 6;
    nix.settings.experimental-features = "nix-command flakes";
    nixpkgs.config.allowUnfree = true;

    # Override fish package to disable tests (they fail on darwin)
    nixpkgs.overlays = [
      (final: prev: {
        fish = prev.fish.overrideAttrs (oldAttrs: {
          doCheck = false;
        });
      })
    ];

    programs.zsh.enable = true;
  };

  den.default.homeManager = {
    home.stateVersion = "25.05";
    home.sessionPath = [
      "$HOME/go/bin"
    ];
    xdg.enable = true;
  };

  den.default.includes = [ den.batteries.hostname ];
}
