{ inputs, ... }:
{
  den.aspects.recordly.homeManager =
    { pkgs, lib, ... }:
    {
      home.activation = {
        configureRecordly = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -d "$HOME/Documents/recordly" ]; then
            echo "Creating Recordly directory... ⚙️"
            $DRY_RUN_CMD mkdir -p "$HOME/Documents/recordly"
            echo "Recordly directory created at $HOME/Documents/recordly ✅"
          fi
        '';

        installRecordly = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          export PATH="${lib.makeBinPath [ pkgs.curl pkgs.jq pkgs.unzip ]}:$PATH"
          export DRY_RUN_CMD
          ${inputs.self + "/scripts/install-github-app.sh"} Recordly webadderallorg/Recordly
        '';
      };
    };
}
