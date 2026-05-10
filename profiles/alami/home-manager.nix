# profiles/alami/home-manager.nix - Alami-specific home-manager config
# Used by: mac-desktop, alami-mbp
{ config, pkgs, lib, ... }:

{
  imports = [
    ./fish
  ];

  # Alami SSH key (decrypted by sops)
  sops.secrets.id_github_alami_group = {
    sopsFile = ../../secrets/id_github_alami_group.enc;
    format = "binary";
    path = "${config.home.homeDirectory}/.ssh/id_github_alami_group";
    mode = "0600";
  };

  home.activation = {
    installAlamiJavaCandidates = lib.hm.dag.entryAfter ["installSdkmanCandidates"] ''
      if [ ! -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
        echo "⚠️  SDKMAN not installed yet, skipping Alami Java installation"
      else
        export SDKMAN_DIR="$HOME/.sdkman"
        export SDKMAN_AUTO_ANSWER=true
        source "$HOME/.sdkman/bin/sdkman-init.sh"

        if [ ! -d "$HOME/.sdkman/candidates/java/17.0.19-tem" ]; then
          echo "Installing java 17.0.19-tem... ⚙️"
          $DRY_RUN_CMD sdk install java 17.0.19-tem
          echo "java 17.0.19-tem installed ✅"
        else
          echo "java 17.0.19-tem already installed ✅"
        fi

        if [ ! -d "$HOME/.sdkman/candidates/java/11.0.31-tem" ]; then
          echo "Installing java 11.0.31-tem... ⚙️"
          $DRY_RUN_CMD sdk install java 11.0.31-tem
          echo "java 11.0.31-tem installed ✅"
        else
          echo "java 11.0.31-tem already installed ✅"
        fi

        echo "Setting default java to 17.0.19-tem... ⚙️"
        $DRY_RUN_CMD sdk default java 17.0.19-tem
        echo "Default java set to 17.0.19-tem ✅"
      fi
    '';

    configureWorkSsh = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Configuring work SSH..."
      $DRY_RUN_CMD mkdir -p "$HOME/.ssh"
      $DRY_RUN_CMD cp ${./dotfiles/ssh/id_github_alami_group.pub} "$HOME/.ssh/id_github_alami_group.pub"
      $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_github_alami_group.pub"

      if ! grep -q "Host alami-group" "$HOME/.ssh/config" 2>/dev/null; then
        echo "" >> "$HOME/.ssh/config"
        $DRY_RUN_CMD cat ${./dotfiles/ssh/config} >> "$HOME/.ssh/config"
      fi
      echo "Work SSH configured"
    '';
  };

  home.file = {
    # SFTPGo config
    ".config/sftpgo/sftpgo.json" = {
      text = builtins.toJSON (import ./dotfiles/sftpgo/config.nix { inherit pkgs; });
      onChange = ''
        echo "SFTPGo config changed"
      '';
    };
    ".config/sftpgo/templates".source = "${pkgs.sftpgo}/share/sftpgo/templates";
    ".config/sftpgo/static".source = "${pkgs.sftpgo}/share/sftpgo/static";
    ".config/sftpgo/openapi".source = "${pkgs.sftpgo}/share/sftpgo/openapi";

    # Git work identity
    ".gitconfig-alami-group" = {
      source = ./dotfiles/git/.gitconfig-alami-group;
      onChange = ''
        echo "Git alami-group config changed"
      '';
    };
  };

  programs.fish.shellAbbrs = {
    mocksftp = "sftpgo serve -c ~/.config/sftpgo";
  };
}
