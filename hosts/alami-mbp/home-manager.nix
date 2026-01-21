# hosts/alami-mbp/home-manager.nix - Office MacBook Pro specific home-manager config
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../programs/fish-git-alami.nix
  ];
  # Sops secrets configuration (work SSH key)
  sops.secrets.id_github_alami_group = {
    sopsFile = ../../secrets/id_github_alami_group.enc;
    format = "binary";
    path = "${config.home.homeDirectory}/.ssh/id_github_alami_group";
    mode = "0600";
  };

  # Activation scripts
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

    configureWorkSsh = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Configuring work SSH..."
      $DRY_RUN_CMD mkdir -p "$HOME/.ssh"
      $DRY_RUN_CMD cp ${../../app-config/hosts/alami-mbp/ssh/id_github_alami_group.pub} "$HOME/.ssh/id_github_alami_group.pub"
      $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_github_alami_group.pub"

      # Append work SSH config if not already present
      if ! grep -q "Host alami-group" "$HOME/.ssh/config" 2>/dev/null; then
        echo "" >> "$HOME/.ssh/config"
        $DRY_RUN_CMD cat ${../../app-config/hosts/alami-mbp/ssh/config} >> "$HOME/.ssh/config"
      fi
      echo "Work SSH configured"
    '';
  };

  # Home file configurations
  home.file = {
    # SFTPGo config
    ".config/sftpgo/sftpgo.json" = {
      text = builtins.toJSON (import ../../app-config/hosts/alami-mbp/sftpgo/config.nix { inherit pkgs; });
      onChange = ''
        echo "SFTPGo config changed"
      '';
    };
    ".config/sftpgo/templates".source = "${pkgs.sftpgo}/share/sftpgo/templates";
    ".config/sftpgo/static".source = "${pkgs.sftpgo}/share/sftpgo/static";
    ".config/sftpgo/openapi".source = "${pkgs.sftpgo}/share/sftpgo/openapi";

    # Git config (host-specific due to username in paths)
    ".gitconfig" = {
      source = ../../app-config/hosts/alami-mbp/git/.gitconfig;
      onChange = ''
        echo "Git config changed"
      '';
    };
    # Git work identity
    ".gitconfig-alami-group" = {
      source = ../../app-config/common/git/.gitconfig-alami-group;
      onChange = ''
        echo "Git alami-group config changed"
      '';
    };
    ".config/flashspace/profiles.json" = {
      source = ../../app-config/hosts/alami-mbp/flashspace/profiles.json;
      force = true;
      onChange = ''
        echo "Flashspace profiles changed"
      '';
    };
    ".config/flashspace/settings.json" = {
      source = ../../app-config/hosts/alami-mbp/flashspace/settings.json;
      force = true;
      onChange = ''
        echo "Flashspace settings changed"
      '';
    };
    ".hammerspoon/home.toml" = {
      source = ../../app-config/hosts/alami-mbp/hammerflow/home.toml;
      onChange = ''
        echo "Hammerspoon home config changed"
      '';
    };
    ".hammerspoon/init.lua" = {
      source = ../../app-config/hosts/alami-mbp/hammerflow/init.lua;
      onChange = ''
        echo "Hammerspoon init config changed"
      '';
    };
  };

  # Shell abbreviations
  programs.fish.shellAbbrs = {
    work = "cd $HOME/work";
    nixalami = "sudo darwin-rebuild switch --flake .#alami-mbp";
    mocksftp = "sftpgo serve -c ~/.config/sftpgo";
  };
}
