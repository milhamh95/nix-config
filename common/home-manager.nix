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
      echo "Configuring SSH..."
      $DRY_RUN_CMD mkdir -p "$HOME/.ssh"

      # Copy public key if not exists
      if [ ! -f "$HOME/.ssh/id_github_personal.pub" ]; then
        $DRY_RUN_CMD cp ${./dotfiles/ssh/id_github_personal.pub} "$HOME/.ssh/id_github_personal.pub"
        $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_github_personal.pub"
      fi

      # Append SSH config only if "Host personal" not already present
      if ! grep -q "Host personal" "$HOME/.ssh/config" 2>/dev/null; then
        echo "Adding personal SSH config..."
        echo "" >> "$HOME/.ssh/config"
        $DRY_RUN_CMD cat ${./dotfiles/ssh/config} >> "$HOME/.ssh/config"
        $DRY_RUN_CMD chmod 600 "$HOME/.ssh/config"
      fi
      echo "SSH configured"
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

    configureRecordly = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/Documents/recordly" ]; then
        echo "Creating Recordly directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/Documents/recordly"
        echo "Recordly directory created at $HOME/Documents/recordly ✅"
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

    installSdkmanCandidates = lib.hm.dag.entryAfter ["configureSdkman"] ''
      if [ ! -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
        echo "⚠️  SDKMAN not installed yet, skipping SDK candidate installation"
      else
        export SDKMAN_DIR="$HOME/.sdkman"
        export SDKMAN_AUTO_ANSWER=true
        source "$HOME/.sdkman/bin/sdkman-init.sh"

        if [ ! -d "$HOME/.sdkman/candidates/maven/3.9.15" ]; then
          echo "Installing maven 3.9.15... ⚙️"
          $DRY_RUN_CMD sdk install maven 3.9.15
          echo "maven 3.9.15 installed ✅"
        else
          echo "maven 3.9.15 already installed ✅"
        fi

        if [ ! -d "$HOME/.sdkman/candidates/java/21.0.11-tem" ]; then
          echo "Installing java 21.0.11-tem... ⚙️"
          $DRY_RUN_CMD sdk install java 21.0.11-tem
          echo "java 21.0.11-tem installed ✅"
        else
          echo "java 21.0.11-tem already installed ✅"
        fi
      fi
    '';

    configureMise = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -d "$HOME/.mise" ]; then
        echo "Creating Mise directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.config/mise"
        echo "Mise directory created at $HOME/.config/mise ✅"

        echo "Copying Mise config files..."
        $DRY_RUN_CMD cp ${./dotfiles/mise/config.toml} "$HOME/.config/mise/config.toml"
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

    configureBatTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Rebuilding bat cache for Catppuccin theme..."
      $DRY_RUN_CMD ${pkgs.bat}/bin/bat cache --build
      echo "Bat cache rebuilt ✅"
    '';

    installRecordly = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Checking Recordly installation..."

      RECORDLY_APP="/Applications/Recordly.app"
      GITHUB_API="https://api.github.com/repos/webadderallorg/Recordly/releases/latest"

      RELEASE_INFO=$(${pkgs.curl}/bin/curl -sf \
        -H "Accept: application/vnd.github.v3+json" \
        "$GITHUB_API" 2>/dev/null || echo "")

      if [ -z "$RELEASE_INFO" ]; then
        echo "⚠️  Could not fetch Recordly release info, skipping..."
      else
        LATEST_VERSION=$(echo "$RELEASE_INFO" | \
          ${pkgs.jq}/bin/jq -r '.tag_name // empty' | sed 's/^v//')
        DOWNLOAD_URL=$(echo "$RELEASE_INFO" | \
          ${pkgs.jq}/bin/jq -r '.assets[] | select(.name | test("\\.(dmg|zip)$"; "i")) | .browser_download_url' | head -1)

        if [ -z "$LATEST_VERSION" ] || [ -z "$DOWNLOAD_URL" ]; then
          echo "⚠️  Could not determine Recordly version or download URL, skipping..."
        else
          INSTALLED_VERSION="none"
          if [ -d "$RECORDLY_APP" ]; then
            INSTALLED_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" \
              "$RECORDLY_APP/Contents/Info.plist" 2>/dev/null || echo "none")
          fi

          if [ "$INSTALLED_VERSION" = "$LATEST_VERSION" ]; then
            echo "Recordly $INSTALLED_VERSION is already up to date ✅"
          else
            echo "Installing Recordly $LATEST_VERSION (installed: $INSTALLED_VERSION)..."
            TEMP_DIR=$(mktemp -d)
            FILENAME=$(basename "$DOWNLOAD_URL")

            if ${pkgs.curl}/bin/curl -L -o "$TEMP_DIR/$FILENAME" "$DOWNLOAD_URL"; then
              echo "Download complete, installing..."

              if echo "$FILENAME" | grep -qi '\.dmg$'; then
                MOUNT_POINT=$(mktemp -d)
                /usr/bin/hdiutil attach "$TEMP_DIR/$FILENAME" -mountpoint "$MOUNT_POINT" -quiet -nobrowse

                APP_PATH=$(find "$MOUNT_POINT" -name "*.app" -maxdepth 2 | head -1)
                if [ -n "$APP_PATH" ]; then
                  [ -d "$RECORDLY_APP" ] && $DRY_RUN_CMD rm -rf "$RECORDLY_APP"
                  $DRY_RUN_CMD cp -R "$APP_PATH" /Applications/
                  echo "Recordly $LATEST_VERSION installed ✅"
                else
                  echo "⚠️  Could not find .app in DMG"
                fi

                /usr/bin/hdiutil detach "$MOUNT_POINT" -quiet
                rm -rf "$MOUNT_POINT"

              elif echo "$FILENAME" | grep -qi '\.zip$'; then
                mkdir -p "$TEMP_DIR/extracted"
                ${pkgs.unzip}/bin/unzip -q "$TEMP_DIR/$FILENAME" -d "$TEMP_DIR/extracted"

                APP_PATH=$(find "$TEMP_DIR/extracted" -name "*.app" -maxdepth 3 | head -1)
                if [ -n "$APP_PATH" ]; then
                  [ -d "$RECORDLY_APP" ] && $DRY_RUN_CMD rm -rf "$RECORDLY_APP"
                  $DRY_RUN_CMD cp -R "$APP_PATH" /Applications/
                  echo "Recordly $LATEST_VERSION installed ✅"
                else
                  echo "⚠️  Could not find .app in ZIP"
                fi

              else
                echo "⚠️  Unknown file format: $FILENAME"
              fi
            else
              echo "⚠️  Failed to download Recordly"
            fi

            rm -rf "$TEMP_DIR"
          fi
        fi
      fi
    '';

    installBetterAudio = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Checking BetterAudio installation..."

      BETTERAUDIO_APP="/Applications/BetterAudio.app"
      GITHUB_API="https://api.github.com/repos/rokartur/BetterAudio/releases/latest"

      RELEASE_INFO=$(${pkgs.curl}/bin/curl -sf \
        -H "Accept: application/vnd.github.v3+json" \
        "$GITHUB_API" 2>/dev/null || echo "")

      if [ -z "$RELEASE_INFO" ]; then
        echo "⚠️  Could not fetch BetterAudio release info, skipping..."
      else
        LATEST_VERSION=$(echo "$RELEASE_INFO" | \
          ${pkgs.jq}/bin/jq -r '.tag_name // empty' | sed 's/^v//')
        DOWNLOAD_URL=$(echo "$RELEASE_INFO" | \
          ${pkgs.jq}/bin/jq -r '.assets[] | select(.name | test("\\.(dmg|zip)$"; "i")) | .browser_download_url' | head -1)

        if [ -z "$LATEST_VERSION" ] || [ -z "$DOWNLOAD_URL" ]; then
          echo "⚠️  Could not determine BetterAudio version or download URL, skipping..."
        else
          INSTALLED_VERSION="none"
          if [ -d "$BETTERAUDIO_APP" ]; then
            INSTALLED_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" \
              "$BETTERAUDIO_APP/Contents/Info.plist" 2>/dev/null || echo "none")
          fi

          if [ "$INSTALLED_VERSION" = "$LATEST_VERSION" ]; then
            echo "BetterAudio $INSTALLED_VERSION is already up to date ✅"
          else
            echo "Installing BetterAudio $LATEST_VERSION (installed: $INSTALLED_VERSION)..."
            TEMP_DIR=$(mktemp -d)
            FILENAME=$(basename "$DOWNLOAD_URL")

            if ${pkgs.curl}/bin/curl -L -o "$TEMP_DIR/$FILENAME" "$DOWNLOAD_URL"; then
              echo "Download complete, installing..."

              if echo "$FILENAME" | grep -qi '\.dmg$'; then
                MOUNT_POINT=$(mktemp -d)
                /usr/bin/hdiutil attach "$TEMP_DIR/$FILENAME" -mountpoint "$MOUNT_POINT" -quiet -nobrowse

                APP_PATH=$(find "$MOUNT_POINT" -name "*.app" -maxdepth 2 | head -1)
                if [ -n "$APP_PATH" ]; then
                  [ -d "$BETTERAUDIO_APP" ] && $DRY_RUN_CMD rm -rf "$BETTERAUDIO_APP"
                  $DRY_RUN_CMD cp -R "$APP_PATH" /Applications/
                  echo "BetterAudio $LATEST_VERSION installed ✅"
                else
                  echo "⚠️  Could not find .app in DMG"
                fi

                /usr/bin/hdiutil detach "$MOUNT_POINT" -quiet
                rm -rf "$MOUNT_POINT"

              elif echo "$FILENAME" | grep -qi '\.zip$'; then
                mkdir -p "$TEMP_DIR/extracted"
                ${pkgs.unzip}/bin/unzip -q "$TEMP_DIR/$FILENAME" -d "$TEMP_DIR/extracted"

                APP_PATH=$(find "$TEMP_DIR/extracted" -name "*.app" -maxdepth 3 | head -1)
                if [ -n "$APP_PATH" ]; then
                  [ -d "$BETTERAUDIO_APP" ] && $DRY_RUN_CMD rm -rf "$BETTERAUDIO_APP"
                  $DRY_RUN_CMD cp -R "$APP_PATH" /Applications/
                  echo "BetterAudio $LATEST_VERSION installed ✅"
                else
                  echo "⚠️  Could not find .app in ZIP"
                fi

              else
                echo "⚠️  Unknown file format: $FILENAME"
              fi
            else
              echo "⚠️  Failed to download BetterAudio"
            fi

            rm -rf "$TEMP_DIR"
          fi
        fi
      fi
    '';
  };

  # Shared home file configurations (common app configs)
  home.file = {
    ".config/karabiner/karabiner.json" = {
      source = ./dotfiles/karabiner/karabiner.json;
      onChange = ''
        echo "Karabiner config changed"
      '';
    };
    # Note: .gitconfig is host-specific (in hosts/{hostname}/home-manager.nix)
    ".gitconfig-personal" = {
      source = ./dotfiles/git/.gitconfig-personal;
      onChange = ''
        echo "Git personal config changed"
      '';
    };
    # Note: .gitconfig-alami-group is mac-desktop only (in hosts/mac-desktop/home-manager.nix)
    ".gitignore" = {
      source = ./dotfiles/git/.gitignore;
      onChange = ''
        echo "Git ignore changed"
      '';
    };
    ".config/git/catppuccin-delta.gitconfig" = {
      source = ./dotfiles/git/catppuccin-delta.gitconfig;
      onChange = ''
        echo "Catppuccin delta theme changed"
      '';
    };
    ".config/bat/config" = {
      source = ./dotfiles/bat/config;
      onChange = ''
        echo "Bat config changed"
      '';
    };
    ".config/bat/themes/Catppuccin Mocha.tmTheme" = {
      source = ./dotfiles/bat/themes/Catppuccin-Mocha.tmTheme;
      onChange = ''
        echo "Bat Catppuccin theme changed"
      '';
    };
    ".config/atuin/themes/catppuccin-mocha-red.toml" = {
      source = ./dotfiles/atuin/themes/catppuccin-mocha-red.toml;
      onChange = ''
        echo "Atuin Catppuccin theme changed"
      '';
    };
    ".config/ghostty/config" = {
      source = ./dotfiles/ghostty/config;
      onChange = ''
        echo "Ghostty config changed"
      '';
    };
    ".wezterm.lua" = {
      source = ./dotfiles/wezterm/wezterm.lua;
      onChange = ''
        echo "WezTerm config changed"
      '';
    };
  };

  home.sessionPath = [
    "$HOME/go/bin"
  ];

  xdg.enable = true;

  imports = [ ./programs ./programs/mise.nix ];
}
