{ pkgs }:

{
  default = pkgs.mkShell {
    packages = with pkgs; [ postgresql_17 redis ];
    shellHook = ''
      echo "Development shell - PostgreSQL and Redis tools available"
      echo "Use: nix develop .#postgres | nix develop .#redis"
    '';
  };

  postgres = import ./postgres.nix { inherit pkgs; };
  redis = import ./redis.nix { inherit pkgs; };
  sops = import ./sops.nix { inherit pkgs; };
}
