# profiles/laptop/system-defaults.nix - Shared laptop system settings
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
