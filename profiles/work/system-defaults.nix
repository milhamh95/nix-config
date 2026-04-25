# profiles/work/system-defaults.nix - Generic work system settings
{
  system.defaults = {
    dock = {
      persistent-apps = [
        { app = "/Applications/Bloom.app"; }
        { spacer = { small = true; }; }
      ];
    };
  };
}
