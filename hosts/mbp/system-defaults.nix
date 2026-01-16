# hosts/mbp/system-defaults.nix - MacBook Pro specific system settings
{
  system.defaults = {
    NSGlobalDomain = {
      # Trackpad-optimized settings
      "com.apple.trackpad.scaling" = 1.5;
    };

    dock = {
      # Smaller dock for laptop screen
      tilesize = 50;

      # Laptop-specific dock apps (streamlined)
      persistent-apps = [
        { app = "/Applications/Spark.app"; }
        { app = "/Applications/Slack.app"; }
        { spacer = { small = true; }; }
        { app = "/Applications/Windsurf.app"; }
        { app = "/Applications/Ghostty.app"; }
        { spacer = { small = true; }; }
        { app = "/Applications/Brave Browser.app"; }
      ];
    };

    controlcenter = {
      # Battery percentage critical for laptop
      BatteryShowPercentage = true;
    };

    universalaccess = {
      # Slightly larger cursor for smaller screen
      mouseDriverCursorSize = 1.5;
    };
  };
}
