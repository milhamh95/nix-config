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
      $DRY_RUN_CMD cp ${../../dotfiles/common/ssh/id_github_alami_group.pub} "$HOME/.ssh/id_github_alami_group.pub"
      $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_github_alami_group.pub"

      if ! grep -q "Host alami-group" "$HOME/.ssh/config" 2>/dev/null; then
        echo "" >> "$HOME/.ssh/config"
        $DRY_RUN_CMD cat ${../../dotfiles/common/ssh/config-work} >> "$HOME/.ssh/config"
      fi
      echo "Work SSH configured"
    '';
  };

  home.file = {
    # SFTPGo config
    ".config/sftpgo/sftpgo.json" = {
      text = builtins.toJSON (import ../../dotfiles/common/sftpgo/config.nix { inherit pkgs; });
      onChange = ''
        echo "SFTPGo config changed"
      '';
    };
    ".config/sftpgo/templates".source = "${pkgs.sftpgo}/share/sftpgo/templates";
    ".config/sftpgo/static".source = "${pkgs.sftpgo}/share/sftpgo/static";
    ".config/sftpgo/openapi".source = "${pkgs.sftpgo}/share/sftpgo/openapi";

    # Git work identity
    ".gitconfig-alami-group" = {
      source = ../../dotfiles/common/git/.gitconfig-alami-group;
      onChange = ''
        echo "Git alami-group config changed"
      '';
    };
  };

  programs.fish.shellAbbrs = {
    mocksftp = "sftpgo serve -c ~/.config/sftpgo";
  };
}
