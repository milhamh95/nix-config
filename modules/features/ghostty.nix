{
  den.aspects.ghostty.darwin.homebrew.casks = [ "ghostty" ];

  den.aspects.ghostty.homeManager.programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      font-size = 16;
      font-family = "BlexMono Nerd Font Mono";
      theme = "Catppuccin Mocha";
      cursor-style = "bar";
      cursor-style-blink = true;
      bold-is-bright = true;
      confirm-close-surface = false;
      command = "/run/current-system/sw/bin/fish";
      shell-integration = "fish";
      macos-titlebar-style = "transparent";
      macos-option-as-alt = true;
      macos-window-shadow = true;
      custom-shader-animation = true;
      window-padding-x = 8;
      window-padding-y = 5;
      window-padding-color = "extend";
      background-opacity = 1;
      window-inherit-working-directory = false;
      tab-inherit-working-directory = false;
      working-directory = "home";
      keybind = [
        "super+alt+left=previous_tab"
        "super+alt+right=next_tab"
      ];
    };
  };
}
