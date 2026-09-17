{ inputs, ... }:
{
  den.aspects.bat.homeManager.programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
    };
    themes = {
      "Catppuccin Mocha" = {
        src = inputs.self + "/dotfiles/bat/themes/Catppuccin-Mocha.tmTheme";
      };
    };
  };
}
