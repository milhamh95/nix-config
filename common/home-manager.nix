# common/home-manager.nix - Shared home-manager configuration
{ config, pkgs, lib, ... }:
let
  enableSecrets = !(builtins.pathExists ../secrets/.skip);
in {
  home.stateVersion = "25.05";

  # Sops secrets configuration (skipped if secrets/.skip exists)
  sops = lib.mkIf enableSecrets {
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
    ".config/atuin/themes/catppuccin-mocha-red.toml" = {
      source = ./dotfiles/atuin/themes/catppuccin-mocha-red.toml;
      onChange = ''
        echo "Atuin Catppuccin theme changed"
      '';
    };
    ".ssh/id_github_personal.pub" = {
      source = ./dotfiles/ssh/id_github_personal.pub;
    };
    ".ssh/known_hosts" = {
      text = ''
        github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
        ssh.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
      '';
    };
    "Applications/KickApp.app" = {
      source = ./dotfiles/kickapp/KickApp.app;
      recursive = true;
    };
  };

  home.sessionPath = [
    "$HOME/go/bin"
  ];

  programs.ghostty = {
    enable = true;
    package = pkgs.emptyDirectory;
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

  programs.ssh = {
    enable = true;
    includes = [ "~/.orbstack/ssh/config" ];
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        userKnownHostsFile = "~/.ssh/known_hosts";
      };
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
        identityFile = "~/.ssh/id_github_personal";
        identitiesOnly = true;
        extraOptions = {
          UseKeychain = "yes";
        };
      };
    };
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
    };
    themes = {
      "Catppuccin Mocha" = {
        src = ./dotfiles/bat/themes/Catppuccin-Mocha.tmTheme;
      };
    };
  };

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Muhammmad Ilham Hidayat";
        email = "m.ilham.hidayat.95@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      core = {
        excludesfile = "~/.gitignore";
        editor = "code --wait";
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      filter.lfs = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };
      url."git@github.com:".insteadOf = "https://github.com/";
    };

    includes = [
      { path = "~/.config/git/catppuccin-delta.gitconfig"; }
    ];
  };

  programs.wezterm = {
    enable = true;
    package = pkgs.emptyDirectory;
    extraConfig = builtins.readFile ./dotfiles/wezterm/wezterm.lua;
  };

  programs.delta = {
    enable = true;
    options = {
      features = "catppuccin-mocha";
      navigate = true;
      line-numbers = true;
      side-by-side = false;
    };
  };

  xdg.enable = true;

  imports = [ ./programs ./programs/mise.nix ];
}
