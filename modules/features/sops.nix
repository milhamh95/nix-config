{ inputs, ... }:
{
  den.aspects.sops.homeManager =
    { config, lib, ... }:
    let
      # Default: secrets ON. To skip (e.g. cloning without the age key),
      # pass --impure and NIX_SKIP_SECRETS=1 — see `make switch-nosecrets`.
      # builtins.getEnv silently returns "" without --impure, so a plain
      # `darwin-rebuild switch --flake .` always keeps secrets enabled.
      enableSecrets = (builtins.getEnv "NIX_SKIP_SECRETS") != "1";
    in
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      sops = lib.mkIf enableSecrets {
        age.keyFile = "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt";

        secrets.id_github_personal = {
          sopsFile = inputs.self + "/secrets/id_github_personal.enc";
          format = "binary";
          path = "${config.home.homeDirectory}/.ssh/id_github_personal";
          mode = "0600";
        };
      };
    };
}
