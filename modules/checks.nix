# Makes `nix flake check` actually build both hosts, not just flake-file's
# own check. Without this, a broken darwinConfiguration still passes `make
# check` — perSystem checks only run on the system they're defined for, so
# these live under aarch64-darwin (the only system both hosts build for).
{ self, lib, ... }:
{
  perSystem =
    { system, ... }:
    {
      checks = builtins.mapAttrs (
        _: cfg: cfg.config.system.build.toplevel
      ) (lib.filterAttrs (_: cfg: cfg.pkgs.stdenv.hostPlatform.system == system) self.darwinConfigurations);
    };
}
