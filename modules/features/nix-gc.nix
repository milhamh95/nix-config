# Weekly garbage collection + store optimisation, so /nix/store doesn't
# grow unbounded between manual `make clean` runs.
{
  den.aspects.nix-gc.darwin = {
    nix.gc = {
      automatic = true;
      interval = {
        Weekday = 5; # Friday
        Hour = 12;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };

    nix.optimise.automatic = true;
  };
}
