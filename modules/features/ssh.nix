{ inputs, ... }:
{
  den.aspects.ssh.homeManager =
    { lib, ... }:
    {
      home.file.".ssh/id_github_personal.pub" = {
        source = inputs.self + "/dotfiles/ssh/id_github_personal.pub";
      };

      # known_hosts must stay writable (ssh appends new host keys to it on
      # first connect), so it can't be a nix-managed home.file like the
      # rest of this aspect. Seed it once with the pinned github.com keys
      # instead — idempotent, leaves anything ssh added later untouched.
      home.activation.seedKnownHosts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p "$HOME/.ssh"
        $DRY_RUN_CMD touch "$HOME/.ssh/known_hosts"
        for line in \
          "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl" \
          "ssh.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"; do
          grep -qxF "$line" "$HOME/.ssh/known_hosts" || $DRY_RUN_CMD bash -c "echo \"$line\" >> \"$HOME/.ssh/known_hosts\""
        done
        $DRY_RUN_CMD chmod 600 "$HOME/.ssh/known_hosts"
      '';

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        includes = [ "~/.orbstack/ssh/config" ];
        settings = {
          "*" = {
            AddKeysToAgent = "yes";
            UserKnownHostsFile = "~/.ssh/known_hosts";
          };
          "github.com" = {
            HostName = "ssh.github.com";
            Port = 443;
            User = "git";
            IdentityFile = "~/.ssh/id_github_personal";
            IdentitiesOnly = true;
            UseKeychain = "yes";
          };
        };
      };
    };
}
