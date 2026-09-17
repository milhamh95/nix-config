{ self, ... }:
{
  den.aspects.karabiner.darwin.homebrew.casks = [ "karabiner-elements" ];

  den.aspects.karabiner.homeManager =
    { lib, ... }:
    {
      home.file.".config/karabiner/karabiner.json" = self.lib.dotfile {
        path = "karabiner/karabiner.json";
        label = "Karabiner config";
      };

      home.activation.configureKarabiner = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
        if [ -f "$HOME/.config/karabiner/karabiner.json.backup" ]; then
          echo "Removing existing Karabiner backup file..."
          $DRY_RUN_CMD rm -f "$HOME/.config/karabiner/karabiner.json.backup"
          echo "Karabiner backup file removed ✅"
        fi
      '';
    };
}
