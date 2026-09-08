# hosts/mbp/system-defaults.nix - MacBook Pro specific system settings
{
  system.defaults = {
    controlcenter = {
      # Battery percentage critical for laptop
      BatteryShowPercentage = true;
    };
  };
}
