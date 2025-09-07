{ hostname }: { config, pkgs, lib, ... }: {
  home.stateVersion = "25.05";

  home.activation = {
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

    configureMise = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/.mise" ]; then
        echo "Creating Mise directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.mise"
        echo "Mise directory created at $HOME/.mise ✅"

        echo "Copying Mise config files..."
        $DRY_RUN_CMD cp ${./app-config/mise/config.toml} "$HOME/.mise/config.toml"
        echo "Mise configured ✅"
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
    configureKarabiner = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ -f "$HOME/.config/karabiner/karabiner.json.backup" ]; then
        echo "Removing existing Karabiner backup file..."
        $DRY_RUN_CMD rm -f "$HOME/.config/karabiner/karabiner.json.backup"
        echo "Karabiner backup file removed ✅"
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
    ".config/sftpgo/sftpgo.json" = {
      text = builtins.toJSON (import ./app-config/sftpgo/config.nix { inherit pkgs; });
      onChange = ''
        echo "SFTPGo config changed"
      '';
    };
    ".config/sftpgo/templates".source = "${pkgs.sftpgo}/share/sftpgo/templates";
    ".config/sftpgo/static".source = "${pkgs.sftpgo}/share/sftpgo/static";
    ".config/sftpgo/openapi".source = "${pkgs.sftpgo}/share/sftpgo/openapi";
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
    ".gitconfig" = {
      source = ./app-config/git/.gitconfig;
      onChange = ''
        echo "Git config changed"
      '';
    };
    ".gitconfig-personal" = {
      source = ./app-config/git/.gitconfig-personal;
      onChange = ''
        echo "Git personal config changed"
      '';
    };
    ".gitconfig-alami-group" = {
      source = ./app-config/git/.gitconfig-alami-group;
      onChange = ''
        echo "Git alami-group config changed"
      '';
    };
    ".gitignore" = {
      source = ./app-config/git/.gitignore;
      onChange = ''
        echo "Git ignore changed"
      '';
    };
  };

  home.sessionPath = [
    "$HOME/go/bin"
  ];

  xdg.enable = true;

  imports = [ ./programs ];
}
