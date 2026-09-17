# Every machine gets a ~/personal folder — part of `common`, not a plug.
{
  den.aspects.personal-folder.homeManager =
    { lib, ... }:
    {
      home.activation.configurePersonalFolder = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -d "$HOME/personal" ]; then
          echo "Creating Personal directory... ⚙️"
          $DRY_RUN_CMD mkdir -p "$HOME/personal"
          echo "Personal directory created at $HOME/personal ✅"
        fi
      '';
    };
}
