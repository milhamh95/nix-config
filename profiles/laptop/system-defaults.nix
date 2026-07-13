# profiles/laptop/system-defaults.nix - Shared laptop system settings
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
