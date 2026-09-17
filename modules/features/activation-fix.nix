{
  den.aspects.activation-fix.homeManager =
    { pkgs, lib, ... }:
    {
      # Override readlink with GNU version before setupLaunchAgents runs.
      # home-manager's launchd module uses readlink -m (GNU-only flag not in macOS BSD readlink).
      # Using a bash function bypasses PATH ordering entirely.
      home.activation.fixReadlinkM = lib.hm.dag.entryBefore [ "setupLaunchAgents" ] ''
        readlink() { ${pkgs.coreutils}/bin/readlink "$@"; }
        install() { ${pkgs.coreutils}/bin/install "$@"; }
      '';

      # Pre-existing dotfiles (not yet nix-managed) would otherwise abort
      # the whole activation; back them up instead of failing the switch.
      home.backupFileExtension = "backup";
    };
}
