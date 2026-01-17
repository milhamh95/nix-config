# common/home-manager.nix - Shared home-manager configuration
{ config, pkgs, lib, ... }: {
  home.stateVersion = "25.05";

  # Sops secrets configuration
  sops = {
    age.keyFile = "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt";

    secrets.id_github_personal = {
      sopsFile = ../secrets/id_github_personal.enc;
      format = "binary";
      path = "${config.home.homeDirectory}/.ssh/id_github_personal";
      mode = "0600";
    };
  };

  # Shared activation scripts
  home.activation = {
    configureSsh = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e "$HOME/ssh_configured" ]; then
        echo "Configuring SSH... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.ssh"
        $DRY_RUN_CMD cp ${../app-config/common/ssh/id_github_personal.pub} "$HOME/.ssh/id_github_personal.pub"
        $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_github_personal.pub"

        echo "Setting up SSH config..."
        if [ -f "$HOME/.ssh/config" ]; then
          echo "Appending to existing SSH config..."
          $DRY_RUN_CMD cat ${../app-config/common/ssh/config} >> "$HOME/.ssh/config"
        else
          echo "Creating new SSH config..."
          $DRY_RUN_CMD cp ${../app-config/common/ssh/config} "$HOME/.ssh/config"
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

    configureShottr = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/Documents/shottr" ]; then
        echo "Creating Shottr directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/Documents/shottr"
        echo "Shottr directory created at $HOME/Documents/shottr ✅"
      fi
    '';

    configureCap = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/Documents/cap" ]; then
        echo "Creating Cap directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/Documents/cap"
        echo "Cap directory created at $HOME/Documents/cap ✅"
      fi
    '';

    configureMise = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/.mise" ]; then
        echo "Creating Mise directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.config/mise"
        echo "Mise directory created at $HOME/.config/mise ✅"

        echo "Copying Mise config files..."
        $DRY_RUN_CMD cp ${../app-config/common/mise/config.toml} "$HOME/.config/mise/config.toml"
        echo "Mise configured ✅"

        echo "Installing Mise tools... ⚙️"
        $DRY_RUN_CMD /opt/homebrew/bin/mise install -y
        echo "Mise tools installed ✅"
      fi
    '';

    configurePersonalFolder = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/personal" ]; then
        echo "Creating Personal directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/personal"
        echo "Personal directory created at $HOME/personal ✅"
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
      if [ ! -d "$HOME/.hammerspoon/Spoons/Hammerflow.spoon" ]; then
        echo "Creating Hammerspoon directories... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.hammerspoon/Spoons"

        echo "Cloning Hammerflow repository... ⚙️"
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/saml-dev/Hammerflow.spoon.git "$HOME/.hammerspoon/Spoons/Hammerflow.spoon"
        echo "Hammerflow configured ✅"
      fi
    '';
  };

  # Shared home file configurations (common app configs)
  home.file = {
    ".config/karabiner/karabiner.json" = {
      source = ../app-config/common/karabiner/karabiner.json;
      onChange = ''
        echo "Karabiner config changed"
      '';
    };
    # Note: .gitconfig is host-specific (in hosts/{hostname}/home-manager.nix)
    ".gitconfig-personal" = {
      source = ../app-config/common/git/.gitconfig-personal;
      onChange = ''
        echo "Git personal config changed"
      '';
    };
    # Note: .gitconfig-alami-group is mac-desktop only (in hosts/mac-desktop/home-manager.nix)
    ".gitignore" = {
      source = ../app-config/common/git/.gitignore;
      onChange = ''
        echo "Git ignore changed"
      '';
    };
    ".config/ghostty/config" = {
      source = ../app-config/common/ghostty/config;
      onChange = ''
        echo "Ghostty config changed"
      '';
    };
    ".wezterm.lua" = {
      source = ../app-config/common/wezterm/wezterm.lua;
      onChange = ''
        echo "WezTerm config changed"
      '';
    };
  };

  home.sessionPath = [
    "$HOME/go/bin"
  ];

  xdg.enable = true;

  imports = [ ../programs ];
}
