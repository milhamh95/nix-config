{ inputs, den, self, ... }:
{
  den.aspects.mac-desktop.darwin = {
    system.defaults.controlcenter.BatteryShowPercentage = false;
    homebrew.casks = [
      "bettermouse"
      "bettertouchtool"
      "betterdisplay"
      "rectangle-pro"
    ];
  };

  # PLUG: work layer. Delete this line to unplug.
  den.aspects.mac-desktop.provides.to-users.includes = [ den.aspects.work ];

  # Host-specific dotfiles: home.file at host scope is inert, so this must
  # go through provides.to-users to actually reach the user's HM eval.
  # This whole block is a function so `lib` resolves to home-manager's own
  # lib (with `.hm.dag`), not the outer flake-parts lib.
  den.aspects.mac-desktop.provides.to-users.homeManager =
    { lib, ... }:
    {
      home.file = {
        ".config/flashspace/profiles.json" = self.lib.dotfile {
          path = "mac-desktop/flashspace/profiles.json";
          label = "Flashspace profiles";
          force = true;
        };
        ".config/flashspace/settings.json" = self.lib.dotfile {
          path = "mac-desktop/flashspace/settings.json";
          label = "Flashspace settings";
          force = true;
        };
        ".config/kickapp/config.json" = self.lib.dotfile {
          path = "mac-desktop/kickapp/config.json";
          label = "KickApp config";
          force = true;
        };
        ".config/switor/config.json" = self.lib.dotfile {
          path = "mac-desktop/switor/config.json";
          label = "Switor config";
          force = true;
        };
      };

      programs.fish.shellAbbrs = {
        nixmd = "sudo darwin-rebuild switch --flake .#mac-desktop";
      };

      home.activation.installSwitor = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        echo "Checking Switor installation..."
        SWITOR_APP="/Applications/Switor.app"
        SOURCE_APP="${inputs.self}/dotfiles/mac-desktop/switor/Switor.app"

        if [ -d "$SWITOR_APP" ]; then
          echo "Switor is already installed ✅"
        else
          echo "Installing Switor to /Applications..."
          $DRY_RUN_CMD cp -R "$SOURCE_APP" /Applications/
          echo "Switor installed successfully ✅"
        fi
      '';
    };
}
