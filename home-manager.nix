{ hostname }: { config, pkgs, lib, ... }: {
  home.stateVersion = "25.05";

  home.activation = {
    configureGit = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e "$HOME/git_configured" ]; then
        echo "Configuring Git... ⚙️"

        echo "Copying Git config files..."
        $DRY_RUN_CMD cp ${./app-config/git/.gitconfig} "$HOME/.gitconfig"
        $DRY_RUN_CMD cp ${./app-config/git/.gitconfig-personal} "$HOME/.gitconfig-personal"
        $DRY_RUN_CMD cp ${./app-config/git/.gitignore} "$HOME/.gitignore"

        $DRY_RUN_CMD touch "$HOME/git_configured"
        echo "Git configured ✅"
      fi
    '';
    configureSsh = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e "$HOME/ssh_configured" ]; then
        echo "Configuring SSH... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.ssh"
        $DRY_RUN_CMD cp ${./app-config/ssh/id_github_personal.pub} "$HOME/.ssh/id_github_personal.pub"
        $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_github_personal.pub"

        echo "Setting up SSH config..."
        if [ -f "$HOME/.ssh/config" ]; then
          echo "Appending to existing SSH config..."
          $DRY_RUN_CMD cat ${./app-config/ssh/config} >> "$HOME/.ssh/config"
        else
          echo "Creating new SSH config..."
          $DRY_RUN_CMD cp ${./app-config/ssh/config} "$HOME/.ssh/config"
        fi
        $DRY_RUN_CMD chmod 600 "$HOME/.ssh/config"

        $DRY_RUN_CMD touch "$HOME/ssh_configured"
        echo "SSH configured ✅"
      fi
    '';
    configureTide = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e "$HOME/.config/fish/tide_configured" ]; then
        echo "Configuring Tide... ⚙️"
        export TERM=xterm-256color
        $DRY_RUN_CMD ${pkgs.fish}/bin/fish -c 'tide configure --auto --style=Rainbow --prompt_colors="True color" --show_time=No --rainbow_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style="Two lines, character and frame" --prompt_connection=Disconnected --powerline_right_prompt_frame=Yes --prompt_connection_andor_frame_color=Lightest --prompt_spacing=Sparse --icons="Many icons" --transient=No'
        $DRY_RUN_CMD touch "$HOME/.config/fish/tide_configured"
        echo "Finish Configuring Tide... ✅"
      fi
    '';
    configureCleanShot = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/Documents/cleanshot" ]; then
        echo "Creating CleanShot directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/Documents/cleanshot"
        echo "CleanShot directory created at $HOME/Documents/cleanshot ✅"
      fi
    '';
    configureWorkFolder = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/work" ]; then
        echo "Creating Work directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/work"
        echo "Work directory created at $HOME/work ✅"
      fi
    '';
    configurePersonalFolder = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/personal" ]; then
        echo "Creating Personal directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/personal"
        echo "Personal directory created at $HOME/personal ✅"
      fi
    '';
    configureSdkman = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e "$HOME/sdkman_configured" ]; then
        echo "Configuring SDKMAN... ⚙️"
        export PATH="/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
        /usr/bin/curl -s "https://get.sdkman.io" | /bin/bash
        $DRY_RUN_CMD touch "$HOME/sdkman_configured"
        echo "SDKMAN configured ✅"
      fi
    '';
    configureFastfetch = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ ! -d "$HOME/.config/fastfetch" ]; then
        echo "Configuring Fastfetch... ⚙️"
        $DRY_RUN_CMD ${pkgs.fastfetch}/bin/fastfetch  --gen-config
        if [ -d "$HOME/.config/fastfetch" ]; then
          echo "Fastfetch configured ✅"
        else
          echo "⚠️ Something is wrong when configuring Fastfetch"
        fi
      fi
    '';
    configureGhostty = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ ! -d "$HOME/.config/ghostty" ]; then
        echo "Creating Ghostty config directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.config/ghostty"
        echo "Copying initial Ghostty config... ⚙️"
        $DRY_RUN_CMD cp ${./app-config/ghostty/config} "$HOME/.config/ghostty/config"
        echo "Ghostty configured ✅"
      fi
    '';
    configureFlashspace = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ ! -d "$HOME/.config/flashspace" ]; then
        echo "Creating FlashSpace config directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.config/flashspace"
        echo "Copying FlashSpace config files..."
        $DRY_RUN_CMD cp ${./app-config/flashspace/settings.json} "$HOME/.config/flashspace/settings.json"
        $DRY_RUN_CMD cp ${./app-config/flashspace/profiles.json} "$HOME/.config/flashspace/profiles.json"
        echo "FlashSpace configured ✅"
      fi
    '';
    configureKarabiner = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ ! -d "$HOME/.config/karabiner" ]; then
        echo "Creating Karabiner config directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.config/karabiner"
        echo "Copying Karabiner config file..."
        $DRY_RUN_CMD cp ${./app-config/karabiner/karabiner.json} "$HOME/.config/karabiner/karabiner.json"
        echo "Karabiner configured ✅"
      fi

      if [ -f "$HOME/.config/karabiner/karabiner.json.backup" ]; then
        echo "Removing existing Karabiner backup file..."
        $DRY_RUN_CMD rm -f "$HOME/.config/karabiner/karabiner.json.backup"
        echo "Karabiner backup file removed ✅"
      fi
    '';
    configureWezTerm = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ ! -f "$HOME/.wezterm.lua" ]; then
        echo "Creating WezTerm config... ⚙️"
        $DRY_RUN_CMD cp ${./app-config/wezterm/wezterm.lua} "$HOME/.wezterm.lua"
        echo "WezTerm config created ✅"
      fi
    '';
    configureHammerflow = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ ! -d "$HOME/.hammerspoon" ]; then
        echo "Creating Hammerspoon directories... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.hammerspoon"

        echo "Cloning Hammerflow repository... ⚙️"
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/saml-dev/Hammerflow.spoon.git "$HOME/.hammerspoon/Spoons/Hammerflow.spoon"

        echo "Copying Hammerflow config files..."
        $DRY_RUN_CMD cp ${./app-config/hammerflow/home.toml} "$HOME/.hammerspoon/home.toml"
        $DRY_RUN_CMD cp ${./app-config/hammerflow/init.lua} "$HOME/.hammerspoon/init.lua"
        echo "Hammerflow configured ✅"
      fi
    '';
  };

  home.file = {
    ".config/ghostty/config" = {
      source = ./app-config/ghostty/config;
      onChange = ''
        echo "Ghostty config changed"
      '';
    };
    ".config/flashspace/profiles.json" = {
      source = ./app-config/flashspace/profiles.json;
      onChange = ''
        echo "Flashspace profiles changed"
      '';
    };
    ".config/flashspace/settings.json" = {
      source = ./app-config/flashspace/settings.json;
      onChange = ''
        echo "Flashspace settings changed"
      '';
    };
    ".config/karabiner/karabiner.json" = {
      source = ./app-config/karabiner/karabiner.json;
      onChange = ''
        echo "Karabiner config changed"
      '';
    };
    ".wezterm.lua" = {
      source = ./app-config/wezterm/wezterm.lua;
      onChange = ''
        echo "WezTerm config changed"
      '';
    };
    ".hammerspoon/home.toml" = {
      source = ./app-config/hammerflow/home.toml;
      onChange = ''
        echo "Hammerspoon home config changed"
      '';
    };
    ".hammerspoon/init.lua" = {
      source = ./app-config/hammerflow/init.lua;
      onChange = ''
        echo "Hammerspoon init config changed"
      '';
    };
    ".config/sftpgo/sftpgo.json" = {
      source = ./app-config/sftpgo/sftpgo.json;
      onChange = ''
        echo "SFTPGo config changed"
      '';
    };
  };

  home.sessionPath = [
    "$HOME/go/bin"
  ];

  xdg.enable = true;

  imports = [ ./programs ];
}
