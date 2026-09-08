# hosts/mac-desktop/system-defaults.nix - Mac Desktop specific system settings
{
  system.defaults = {
    controlcenter = {
      # Battery percentage less critical on desktop (always plugged in)
      BatteryShowPercentage = false;
    };
  };
}
