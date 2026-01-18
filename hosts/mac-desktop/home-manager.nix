# hosts/mac-desktop/home-manager.nix - Mac Desktop specific home-manager config
{ config, pkgs, lib, ... }:

{
  # Sops secrets configuration (mac-desktop only)
  sops.secrets.id_github_alami_group = {
    sopsFile = ../../secrets/id_github_alami_group.enc;
    format = "binary";
    path = "${config.home.homeDirectory}/.ssh/id_github_alami_group";
    mode = "0600";
  };

  # Desktop-specific activation scripts
  home.activation = {
    configureWorkFolder = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -d "$HOME/work" ]; then
        echo "Creating Work directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/work"
        echo "Work directory created at $HOME/work ✅"
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

    installSoundSource = let
      soundsourceVersion = "5.8.12";
      soundsourceUrl = "https://rogueamoeba.com/legacy/downloads/SoundSource-5812.zip";
    in lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Checking SoundSource installation..."

      SOUNDSOURCE_APP="/Applications/SoundSource.app"
      TEMP_DIR=$(mktemp -d)

      # Check if SoundSource is already installed with the correct version
      if [ -d "$SOUNDSOURCE_APP" ]; then
        INSTALLED_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$SOUNDSOURCE_APP/Contents/Info.plist" 2>/dev/null || echo "unknown")
        if [ "$INSTALLED_VERSION" = "${soundsourceVersion}" ]; then
          echo "SoundSource ${soundsourceVersion} is already installed ✅"
        else
          echo "Found SoundSource version $INSTALLED_VERSION, will install ${soundsourceVersion}"

          echo "Downloading SoundSource ${soundsourceVersion}..."
          cd "$TEMP_DIR"

          if ${pkgs.curl}/bin/curl -L -o soundsource.zip "${soundsourceUrl}"; then
            echo "Download complete, extracting..."
            ${pkgs.unzip}/bin/unzip -q soundsource.zip

            APP_PATH=$(find "$TEMP_DIR" -name "SoundSource.app" -type d -maxdepth 2 | head -n 1)

            if [ -n "$APP_PATH" ]; then
              echo "Installing SoundSource to /Applications..."
              $DRY_RUN_CMD rm -rf "$SOUNDSOURCE_APP"
              $DRY_RUN_CMD cp -R "$APP_PATH" /Applications/
              echo "SoundSource ${soundsourceVersion} installed successfully ✅"
            else
              echo "Error: Could not find SoundSource.app in the extracted files"
            fi
          else
            echo "Error: Failed to download SoundSource"
          fi

          rm -rf "$TEMP_DIR"
        fi
      else
        echo "SoundSource not found, installing ${soundsourceVersion}..."
        cd "$TEMP_DIR"

        if ${pkgs.curl}/bin/curl -L -o soundsource.zip "${soundsourceUrl}"; then
          echo "Download complete, extracting..."
          ${pkgs.unzip}/bin/unzip -q soundsource.zip

          APP_PATH=$(find "$TEMP_DIR" -name "SoundSource.app" -type d -maxdepth 2 | head -n 1)

          if [ -n "$APP_PATH" ]; then
            echo "Installing SoundSource to /Applications..."
            $DRY_RUN_CMD cp -R "$APP_PATH" /Applications/
            echo "SoundSource ${soundsourceVersion} installed successfully ✅"
          else
            echo "Error: Could not find SoundSource.app in the extracted files"
          fi
        else
          echo "Error: Failed to download SoundSource"
        fi

        rm -rf "$TEMP_DIR"
      fi
    '';

    configureWorkSsh = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Configuring work SSH..."
      $DRY_RUN_CMD mkdir -p "$HOME/.ssh"
      $DRY_RUN_CMD cp ${../../app-config/hosts/mac-desktop/ssh/id_github_alami_group.pub} "$HOME/.ssh/id_github_alami_group.pub"
      $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_github_alami_group.pub"

      # Append work SSH config if not already present
      if ! grep -q "Host alami-group" "$HOME/.ssh/config" 2>/dev/null; then
        echo "" >> "$HOME/.ssh/config"
        $DRY_RUN_CMD cat ${../../app-config/hosts/mac-desktop/ssh/config} >> "$HOME/.ssh/config"
      fi
      echo "Work SSH configured"
    '';
  };

  # Desktop-specific home file configurations
  home.file = {
    # SFTPGo config (mac-desktop only)
    ".config/sftpgo/sftpgo.json" = {
      text = builtins.toJSON (import ../../app-config/hosts/mac-desktop/sftpgo/config.nix { inherit pkgs; });
      onChange = ''
        echo "SFTPGo config changed"
      '';
    };
    ".config/sftpgo/templates".source = "${pkgs.sftpgo}/share/sftpgo/templates";
    ".config/sftpgo/static".source = "${pkgs.sftpgo}/share/sftpgo/static";
    ".config/sftpgo/openapi".source = "${pkgs.sftpgo}/share/sftpgo/openapi";

    # Git config (host-specific due to username in paths)
    ".gitconfig" = {
      source = ../../app-config/hosts/mac-desktop/git/.gitconfig;
      onChange = ''
        echo "Git config changed"
      '';
    };
    # Git work identity (mac-desktop only)
    ".gitconfig-alami-group" = {
      source = ../../app-config/common/git/.gitconfig-alami-group;
      onChange = ''
        echo "Git alami-group config changed"
      '';
    };
    ".config/flashspace/profiles.json" = {
      source = ../../app-config/hosts/mac-desktop/flashspace/profiles.json;
      onChange = ''
        echo "Flashspace profiles changed"
      '';
    };
    ".config/flashspace/settings.json" = {
      source = ../../app-config/hosts/mac-desktop/flashspace/settings.json;
      onChange = ''
        echo "Flashspace settings changed"
      '';
    };
    ".hammerspoon/home.toml" = {
      source = ../../app-config/hosts/mac-desktop/hammerflow/home.toml;
      onChange = ''
        echo "Hammerspoon home config changed"
      '';
    };
    ".hammerspoon/init.lua" = {
      source = ../../app-config/hosts/mac-desktop/hammerflow/init.lua;
      onChange = ''
        echo "Hammerspoon init config changed"
      '';
    };
  };

  # Desktop-specific shell abbreviations
  programs.fish.shellAbbrs = {
    work = "cd $HOME/work";
    nixmd = "sudo darwin-rebuild switch --flake .#mac-desktop";
    mocksftp = "sftpgo serve -c ~/.config/sftpgo";
  };
}
