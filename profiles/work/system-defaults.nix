# profiles/work/system-defaults.nix - Generic work system settings
{ lib, ... }:

{
  system.defaults = {
    dock = {
      # Prepend Bloom before the common spacer
      persistent-apps = lib.mkBefore [
        { app = "/Applications/Bloom.app"; }
      ];
    };
  };
}
