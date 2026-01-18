# hosts/alami-mbp/system-defaults.nix - Alami MacBook Pro specific system settings
{
  system.defaults = {
    dock = {
      # Smaller dock for laptop screen
      tilesize = 50;

      # Laptop-specific dock apps (streamlined)
      persistent-apps = [
        { app = "/Applications/Bloom.app"; }
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
