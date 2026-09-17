{
  den.aspects.shottr.darwin.homebrew.casks = [ "shottr" ];

  den.aspects.shottr.homeManager =
    { lib, ... }:
    {
      home.activation.configureShottr = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -d "$HOME/Documents/shottr" ]; then
          echo "Creating Shottr directory... ⚙️"
          $DRY_RUN_CMD mkdir -p "$HOME/Documents/shottr"
          echo "Shottr directory created at $HOME/Documents/shottr ✅"
        fi
      '';
    };
}
