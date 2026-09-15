{ inputs, ... }:
{
  den.aspects.wezterm.darwin.homebrew.casks = [ "wezterm" ];

  den.aspects.wezterm.homeManager =
    { pkgs, ... }:
    {
      programs.wezterm = {
        enable = true;
        package = pkgs.emptyDirectory;
        extraConfig = builtins.readFile (inputs.self + "/dotfiles/wezterm/wezterm.lua");
      };
    };
}
