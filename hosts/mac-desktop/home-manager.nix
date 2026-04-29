# hosts/mac-desktop/home-manager.nix - Mac Desktop specific home-manager config
{ config, pkgs, lib, ... }:

{
  home.activation = {
    installSoundSource = let
      soundsourceVersion = "5.8.12";
      soundsourceUrl = "https://rogueamoeba.com/legacy/downloads/SoundSource-5812.zip";
    in lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Checking SoundSource installation..."

      SOUNDSOURCE_APP="/Applications/SoundSource.app"

      # Compare two semver strings: returns 0 if $1 > $2, 1 otherwise
      version_gt() {
        local IFS=.
        local i ver1=($1) ver2=($2)
        for i in 0 1 2; do
          local n1=''${ver1[$i]:-0}
          local n2=''${ver2[$i]:-0}
          if [ "$n1" -gt "$n2" ]; then return 0; fi
          if [ "$n1" -lt "$n2" ]; then return 1; fi
        done
        return 1
      }

      INSTALLED_VERSION="0.0.0"
      if [ -d "$SOUNDSOURCE_APP" ]; then
        INSTALLED_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$SOUNDSOURCE_APP/Contents/Info.plist" 2>/dev/null || echo "0.0.0")
      fi

      if version_gt "$INSTALLED_VERSION" "${soundsourceVersion}"; then
        echo "SoundSource $INSTALLED_VERSION is already installed (newer than ${soundsourceVersion}), skipping ✅"
      elif [ "$INSTALLED_VERSION" = "${soundsourceVersion}" ]; then
        echo "SoundSource ${soundsourceVersion} is already installed ✅"
      else
        echo "Installing SoundSource ${soundsourceVersion}..."
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"

        if ${pkgs.curl}/bin/curl -L -o soundsource.zip "${soundsourceUrl}"; then
          echo "Download complete, extracting..."
          ${pkgs.unzip}/bin/unzip -q soundsource.zip

          APP_PATH=$(find "$TEMP_DIR" -name "SoundSource.app" -type d -maxdepth 2 | head -n 1)

          if [ -n "$APP_PATH" ]; then
            echo "Installing SoundSource to /Applications..."
            [ -d "$SOUNDSOURCE_APP" ] && $DRY_RUN_CMD rm -rf "$SOUNDSOURCE_APP"
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

    installSwitor = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Checking Switor installation..."
      SWITOR_APP="/Applications/Switor.app"
      SOURCE_APP="${./dotfiles/switor/Switor.app}"

      if [ -d "$SWITOR_APP" ]; then
        echo "Switor is already installed ✅"
      else
        echo "Installing Switor to /Applications..."
        $DRY_RUN_CMD cp -R "$SOURCE_APP" /Applications/
        echo "Switor installed successfully ✅"
      fi
    '';
  };

  home.file = {
    # Git config (host-specific)
    ".gitconfig" = {
      source = ./dotfiles/git/.gitconfig;
      onChange = ''
        echo "Git config changed"
      '';
    };
    ".config/flashspace/profiles.json" = {
      source = ./dotfiles/flashspace/profiles.json;
      force = true;
      onChange = ''
        echo "Flashspace profiles changed"
      '';
    };
    ".config/flashspace/settings.json" = {
      source = ./dotfiles/flashspace/settings.json;
      force = true;
      onChange = ''
        echo "Flashspace settings changed"
      '';
    };
    ".hammerspoon/home.toml" = {
      source = ./dotfiles/hammerflow/home.toml;
      onChange = ''
        echo "Hammerspoon home config changed"
      '';
    };
    ".hammerspoon/init.lua" = {
      source = ./dotfiles/hammerflow/init.lua;
      onChange = ''
        echo "Hammerspoon init config changed"
      '';
    };
    ".config/switor/config.json" = {
      source = ./dotfiles/switor/config.json;
      force = true;
      onChange = ''
        echo "Switor config changed"
      '';
    };
  };

  programs.fish.shellAbbrs = {
    nixmd = "sudo darwin-rebuild switch --flake .#mac-desktop";
  };
}
