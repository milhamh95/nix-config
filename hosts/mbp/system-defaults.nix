# hosts/mbp/system-defaults.nix - MacBook Pro specific system settings
{
  system.defaults = {
    dock = {
      # Smaller dock for laptop screen
      tilesize = 65;
    };

    controlcenter = {
      # Battery percentage critical for laptop
      BatteryShowPercentage = true;
    };
  };
}
