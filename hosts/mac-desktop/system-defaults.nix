# hosts/mac-desktop/system-defaults.nix - Mac Desktop specific system settings
{
  system.defaults = {
    NSGlobalDomain = {
      # Trackpad scaling (still useful for built-in if using laptop mode occasionally)
      "com.apple.trackpad.scaling" = 1.5;
    };

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
      # Standard cursor size for large display
      mouseDriverCursorSize = 1.3;
    };
  };
}
