{ self, ... }:
{
  den.aspects.atuin.homeManager = {
    home.file.".config/atuin/themes/catppuccin-mocha-red.toml" = self.lib.dotfile {
      path = "atuin/themes/catppuccin-mocha-red.toml";
      label = "Atuin Catppuccin theme";
    };

    programs.atuin = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        theme = {
          name = "catppuccin-mocha-red";
        };
      };
    };
  };
}
