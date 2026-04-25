# hosts/alami-mbp/system-defaults.nix - Alami MacBook Pro specific system settings
{
  system.defaults = {
    dock = {
      # Smaller dock for laptop screen
      tilesize = 50;
    };

    controlcenter = {
      # Battery percentage critical for laptop
      BatteryShowPercentage = true;
    };
  };
}
