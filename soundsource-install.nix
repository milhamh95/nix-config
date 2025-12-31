# soundsource-install.nix - Custom SoundSource installation
{ config, lib, pkgs, ... }:

let
  soundsourceVersion = "5.8.12";
  soundsourceUrl = "https://rogueamoeba.com/legacy/downloads/SoundSource-5812.zip";
in
{
  system.activationScripts.postUserActivation.text = ''
    # Install SoundSource ${soundsourceVersion}
    echo "Checking SoundSource installation..."
    
    SOUNDSOURCE_APP="/Applications/SoundSource.app"
    TEMP_DIR=$(mktemp -d)
    
    # Check if SoundSource is already installed with the correct version
    if [ -d "$SOUNDSOURCE_APP" ]; then
      INSTALLED_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$SOUNDSOURCE_APP/Contents/Info.plist" 2>/dev/null || echo "unknown")
      if [ "$INSTALLED_VERSION" = "${soundsourceVersion}" ]; then
        echo "SoundSource ${soundsourceVersion} is already installed"
        exit 0
      else
        echo "Found SoundSource version $INSTALLED_VERSION, will install ${soundsourceVersion}"
      fi
    fi
    
    echo "Downloading SoundSource ${soundsourceVersion}..."
    cd "$TEMP_DIR"
    
    if ${pkgs.curl}/bin/curl -L -o soundsource.zip "${soundsourceUrl}"; then
      echo "Download complete, extracting..."
      
      # Extract the zip file
      ${pkgs.unzip}/bin/unzip -q soundsource.zip
      
      # Find the .app file (it might be in a subdirectory)
      APP_PATH=$(find "$TEMP_DIR" -name "SoundSource.app" -type d -maxdepth 2 | head -n 1)
      
      if [ -n "$APP_PATH" ]; then
        echo "Installing SoundSource to /Applications..."
        
        # Remove old version if exists
        if [ -d "$SOUNDSOURCE_APP" ]; then
          rm -rf "$SOUNDSOURCE_APP"
        fi
        
        # Copy to Applications
        cp -R "$APP_PATH" /Applications/
        
        echo "SoundSource ${soundsourceVersion} installed successfully"
      else
        echo "Error: Could not find SoundSource.app in the extracted files"
      fi
    else
      echo "Error: Failed to download SoundSource"
    fi
    
    # Cleanup
    echo "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
  '';
}
