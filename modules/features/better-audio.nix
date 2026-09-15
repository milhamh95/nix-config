{ inputs, ... }:
{
  den.aspects.better-audio.homeManager =
    { pkgs, lib, ... }:
    {
      home.activation.installBetterAudio = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        export PATH="${lib.makeBinPath [ pkgs.curl pkgs.jq pkgs.unzip ]}:$PATH"
        export DRY_RUN_CMD
        ${inputs.self + "/scripts/install-github-app.sh"} BetterAudio rokartur/BetterAudio
      '';
    };
}
