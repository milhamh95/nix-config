# AGENTS.md

Recipes + commands for this repo. Concepts/diagrams: `docs/den.md`.

**Trap:** content on a host aspect's `homeManager` is silently inert — never
reaches the user config, no error. Put user-facing content on the `user`
aspect or route via `provides.to-users`.

**Staging:** nix only evaluates git-tracked files. New `.nix`/dotfile/secret
→ `git add <path>` by name (never `-A`/`.`) before `nix eval` will see it.
Symptom of forgetting: `error: attribute ... missing`.

**Checking:**

```bash
nix eval .#darwinConfigurations.<host>.system.drvPath --raw >/dev/null && echo OK   # seconds, use while iterating
nix build .#darwinConfigurations.<host>.system --no-link                            # minutes, before done
nix flake check                                                                     # builds both hosts, see modules/checks.nix
nix eval .#darwinConfigurations.<host>.config.home-manager.users.milhamh95.<opt>     # inspect one built value
nix run .#write-diagrams                                                            # regen docs/diagrams/den + docs/den.md section after aspect changes
```

**Commits:** Conventional Commits, scoped — `type(scope): summary`. Scope is
the aspect/host/layer touched (`feat(git): ...`, `fix(mbp): ...`,
`docs(den): ...`) or a cross-cutting area (`ci`, `flake`, `secrets`) when no
single aspect fits. Omit scope only for a repo-wide change. Types: `feat`,
`fix`, `docs`, `ref`, `chore`, `test`.

**Dotfile paths:** always `inputs.self + "/dotfiles/..."` (or `self.lib.dotfile`
helper). Never relative — breaks when the referencing file moves.

## Recipe: new feature (app/tool/setting)

`modules/features/<name>.nix`:

```nix
{
  den.aspects.<name>.darwin.homebrew.casks = [ "some-app" ];   # system side
  den.aspects.<name>.homeManager = { pkgs, lib, ... }: {       # user side
    programs.<name>.enable = true;
  };
}
```

Copy a small existing aspect (`bat.nix`, `ghostty.nix`) as a starting point.
All-machines → add to `common.nix` includes. Host-only → plug via that
host's `provides.to-users.includes` (see `mac-desktop.nix`).

## Recipe: new host

1. Copy `modules/hosts/mbp.nix` → `modules/hosts/<host>.nix`.
2. `modules/hosts.nix`: `den.hosts.aarch64-darwin.<host>.users.milhamh95 = { };`
3. Stage both by name, verify with `nix eval .#darwinConfigurations.<host>.system.drvPath --raw`.

## Recipe: new company layer

Gives one employer its own git identity: dedicated SSH key, git email
scoped to `~/work/<company>/`, optional company-only packages. `gclone
<url> <company>` then clones into `~/work/<company>` with that identity —
`gclone` reads company names from `~/.ssh/config` at runtime, so nothing
else needs editing once this exists.

```bash
ssh-keygen -t ed25519 -C "you@company.example" -f secrets/raw/id_github_<company>
sops --encrypt secrets/raw/id_github_<company> > secrets/id_github_<company>.enc
mv secrets/raw/id_github_<company>.pub dotfiles/ssh/id_github_<company>.pub
rm secrets/raw/id_github_<company>   # plaintext private key — never commit
```

`modules/layers/<company>.nix`:

```nix
{ inputs, ... }:
{
  den.aspects.<company>.homeManager =
    { config, lib, ... }:
    let
      enableSecrets = (builtins.getEnv "NIX_SKIP_SECRETS") != "1";
    in
    {
      sops.secrets.id_github_<company> = lib.mkIf enableSecrets {
        sopsFile = inputs.self + "/secrets/id_github_<company>.enc";
        format = "binary";
        path = "${config.home.homeDirectory}/.ssh/id_github_<company>";
        mode = "0600";
      };

      home.file.".ssh/id_github_<company>.pub".source =
        inputs.self + "/dotfiles/ssh/id_github_<company>.pub";

      home.file.".gitconfig-<company>".text = "[user]\n  email = you@company.example\n";

      programs.git.includes = lib.mkAfter [
        { condition = "gitdir:~/work/<company>/**"; path = "~/.gitconfig-<company>"; }
      ];

      programs.ssh.settings."<company>" = {
        HostName = "ssh.github.com";
        Port = 443;
        User = "git";
        IdentityFile = "~/.ssh/id_github_<company>";
        IdentitiesOnly = true;
        UseKeychain = "yes";
      };
    };
}
```

Company-only tooling in the same file: GUI app/CLI → `darwin.homebrew.casks`
(removed on unplug via `homebrew-engine.nix`'s `cleanup = "uninstall"`).
Language/runtime version → usually `.mise.toml` in that company's own repo
instead (mise is already active, scopes per-directory) — only add to nix if
the tool must exist outside any repo.

Plug in: add `den.aspects.<company>` to a host's
`provides.to-users.includes` (`modules/hosts/<host>.nix`). Stage new files
by name. Verify:
```bash
nix eval .#darwinConfigurations.<host>.config.home-manager.users.milhamh95.programs.ssh.settings --apply builtins.attrNames
nix eval .#darwinConfigurations.<host>.config.home-manager.users.milhamh95.sops.secrets.id_github_<company>.path
```

Remove: delete the plug line. `Host` block disappears from `~/.ssh/config`,
`gclone` stops offering it. Aspect/secret/dotfile files can stay (dead,
harmless) or be deleted.
