{ den, self, ... }:
{
  den.aspects.mbp.darwin = {
    system.defaults.controlcenter.BatteryShowPercentage = true;
    homebrew.casks = [ "batfi" ];
  };

  # Host-specific dotfiles: home.file at host scope is inert, so this must
  # go through provides.to-users to actually reach the user's HM eval.
  den.aspects.mbp.provides.to-users.homeManager.home.file = {
    ".config/flashspace/profiles.json" = self.lib.dotfile {
      path = "mbp/flashspace/profiles.json";
      label = "Flashspace profiles";
      force = true;
    };
    ".config/flashspace/settings.json" = self.lib.dotfile {
      path = "mbp/flashspace/settings.json";
      label = "Flashspace settings";
      force = true;
    };
    ".config/kickapp/config.json" = self.lib.dotfile {
      path = "mbp/kickapp/config.json";
      label = "KickApp config";
      force = true;
    };
  };

  den.aspects.mbp.provides.to-users.homeManager.programs.fish.shellAbbrs = {
    nixmbp = "sudo darwin-rebuild switch --flake .#mbp";
  };
}
