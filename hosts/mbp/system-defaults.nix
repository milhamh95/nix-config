# hosts/mbp/system-defaults.nix - MacBook Pro specific system settings
{
  system.defaults = {
    dock = {
      # Smaller dock for laptop screen
      tilesize = 50;

      # Laptop-specific dock apps (streamlined)
      persistent-apps = [
        { spacer = { small = true; }; }
      ];
    };

    controlcenter = {
      # Battery percentage critical for laptop
      BatteryShowPercentage = true;
    };

    universalaccess = {
    };
  };
}
