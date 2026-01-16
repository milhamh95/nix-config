# hosts/mac-desktop/system-defaults.nix - Mac Desktop specific system settings
{
  system.defaults = {
    dock = {
      # Larger dock for external display
      tilesize = 65;

      # Desktop-specific dock apps
      persistent-apps = [
        { app = "/Applications/Bloom.app"; }
        { spacer = { small = true; }; }
      ];
    };

    controlcenter = {
      # Battery percentage less critical on desktop (always plugged in)
      BatteryShowPercentage = false;
    };

    universalaccess = {
    };
  };
}
