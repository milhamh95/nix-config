# Dendritic split plan

Branch: `feat/separate-brew-dendritic`

Goal: every `.nix` file under `modules/` is a flake-parts module.
No import lists. No `lib/mkDarwinConfig.nix`. No `hostConfigs` table.
One topic = one file, across system layer and user layer at the same time.

---

## 1. The new flake.nix

Replace all 122 lines with this:

```nix
{
  description = "Nix Darwin Config for Mac";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./modules);
}
```

`import-tree` reads every `.nix` file below `modules/`, forever.
You never edit `flake.nix` again, except to add an input.

---

## 2. Slot names

Only 8 slots. Every file writes into one or more of them.

| slot | meaning |
|---|---|
| `flake.modules.darwin.base` | all machines, system layer |
| `flake.modules.darwin.work` | work profile, system layer |
| `flake.modules.darwin.mbp` | laptop only, system layer |
| `flake.modules.darwin.mac-desktop` | desktop only, system layer |
| `flake.modules.homeManager.base` | all machines, user layer |
| `flake.modules.homeManager.work` | work profile, user layer |
| `flake.modules.homeManager.mbp` | laptop only, user layer |
| `flake.modules.homeManager.mac-desktop` | desktop only, user layer |

---

## 3. Target file tree

```
flake.nix                          20 lines
dotfiles/                          all assets, one place
modules/
  meta/
    systems.nix                    systems = [ "aarch64-darwin" ]
    nixpkgs.nix                    allowUnfree + fish overlay
    nix-settings.nix               flakes, stateVersion, primaryUser
    user.nix                       users.users.milhamh95
    home-manager.nix               HM darwin module + useGlobalPkgs
    sops.nix                       sops-nix + secret paths
    activation-fix.nix             fixReadlinkM
  darwin/
    packages.nix                   systemPackages + fonts
    system-defaults.nix            macOS defaults (shared)
    homebrew.nix                   brew engine + leftover apps
  programs/
    fish.nix                       fish core + plugins + init
    fish-abbr.nix                  abbreviations
    fish-functions.nix             functions
    fish-git-functions.nix         git functions
    git.nix                        git + delta + lazygit + gh
    ghostty.nix                    ghostty
    wezterm.nix                    wezterm
    ssh.nix                        ssh + known_hosts + pubkey
    bat.nix                        bat + theme
    atuin.nix                      atuin + theme file
    fastfetch.nix                  fastfetch
    mise.nix                       mise
  apps/
    karabiner.nix                  cask + config + activation
    shottr.nix                     cask + activation
    flashspace.nix                 cask + per-host profiles
    recordly.nix                   activation (install + config)
    sdkman.nix                     activation (install + candidates)
    better-audio.nix               activation
    kickapp.nix                    app bundle + config
    browsers.nix                   brave, chrome, chrome@beta
    api-tools.nix                  bruno, mockoon
    window-tools.nix               rectangle-pro, homerow, hammerspoon, ice
    media.nix                      iina, vlc
    desktop.nix                    raycast, rocket, appcleaner, keka, ...
  profiles/
    work.nix                       everything "work"
  hosts/
    mbp.nix                        laptop, system + user + darwinConfiguration
    mac-desktop.nix                desktop, same
  dev/
    postgres.nix                   devShell
    redis.nix                      devShell
    sops.nix                       devShell
    default-shell.nix              default devShell
```

---

## 4. File-by-file split

### 4.1 flake.nix (122 lines) is cut into 6 files

| lines / block | new file | slot |
|---|---|---|
| `systems = [...]` | `modules/meta/systems.nix` | (top-level) |
| `experimental-features`, `stateVersion`, `configurationRevision`, `primaryUser` | `modules/meta/nix-settings.nix` | `darwin.base` |
| `nixpkgs.config.allowUnfree`, `hostPlatform`, fish overlay | `modules/meta/nixpkgs.nix` | `darwin.base` |
| `users.knownUsers`, `users.users.<name>`, `programs.zsh/fish.enable` | `modules/meta/user.nix` | `darwin.base` |
| `hostConfigs` + `mkDarwinConfig` call | `modules/hosts/*.nix` | (see 4.5) |
| `perSystem.devShells` | `modules/dev/*.nix` | (see 4.6) |

`lib/mkDarwinConfig.nix` is deleted. Its whole job is now 8 lines in each host file.

### 4.2 common/home-manager.nix (429 lines) is cut into 15 files

| old lines | block | new file | slot |
|---|---|---|---|
| 6 | `home.stateVersion` | `modules/meta/home-manager.nix` | `homeManager.base` |
| 9-18 | `sops` secrets | `modules/meta/sops.nix` | `homeManager.base` |
| 25-29 | `fixReadlinkM` | `modules/meta/activation-fix.nix` | `homeManager.base` |
| 30-39 | `configureTide` | `modules/programs/fish.nix` | `homeManager.base` |
| 40-47 | `configureShottr` | `modules/apps/shottr.nix` | `homeManager.base` |
| 48-55, 113-191 | `configureRecordly`, `installRecordly` | `modules/apps/recordly.nix` | `homeManager.base` |
| 56-96 | `configureSdkman`, `installSdkmanCandidates` | `modules/apps/sdkman.nix` | `homeManager.base` |
| 97-104 | `configurePersonalFolder` | `modules/profiles/personal.nix` | `homeManager.base` |
| 105-112 | `configureKarabiner` | `modules/apps/karabiner.nix` | `homeManager.base` |
| 192-271 | `installBetterAudio` | `modules/apps/better-audio.nix` | `homeManager.base` |
| 273-278 | `home.file` karabiner.json | `modules/apps/karabiner.nix` | `homeManager.base` |
| 280-291 | `home.file` .gitignore + delta theme | `modules/programs/git.nix` | `homeManager.base` |
| 292-297 | `home.file` atuin theme | `modules/programs/atuin.nix` | `homeManager.base` |
| 298-311 | `home.file` ssh pubkey + known_hosts | `modules/programs/ssh.nix` | `homeManager.base` |
| 305-311 | `home.file` KickApp.app | `modules/apps/kickapp.nix` | `homeManager.base` |
| 313-315 | `home.sessionPath` | `modules/meta/home-manager.nix` | `homeManager.base` |
| 317-347 | `programs.ghostty` | `modules/programs/ghostty.nix` | `homeManager.base` |
| 348-367 | `programs.ssh` | `modules/programs/ssh.nix` | `homeManager.base` |
| 368-379 | `programs.bat` | `modules/programs/bat.nix` | `homeManager.base` |
| 380-409 | `programs.git` | `modules/programs/git.nix` | `homeManager.base` |
| 410-415 | `programs.wezterm` | `modules/programs/wezterm.nix` | `homeManager.base` |
| 416-425 | `programs.delta` | `modules/programs/git.nix` | `homeManager.base` |
| 426 | `xdg.enable` | `modules/meta/home-manager.nix` | `homeManager.base` |
| 428 | `imports = [ ./programs ... ]` | deleted, `import-tree` replaces it | - |

### 4.3 common/homebrew.nix (75 lines) is cut by app

The brew engine stays in one file. Each app moves to its topic file.

**`modules/darwin/homebrew.nix`** keeps only the engine:

```nix
{
  flake.modules.darwin.base = { config, lib, ... }: {
    environment.shellInit = lib.mkIf config.homebrew.enable ''
      eval "$(${config.homebrew.prefix}/bin/brew shellenv)"
    '';
    homebrew = {
      enable = true;
      taps = [ ];
      onActivation.autoUpdate = true;
      onActivation.upgrade = true;
    };
  };
}
```

Then each app writes its own cask:

| cask / brew | goes to |
|---|---|
| `gh` | `modules/programs/git.nix` |
| `bash`, `mas`, `mole` | `modules/darwin/homebrew.nix` |
| `ghostty` | `modules/programs/ghostty.nix` |
| `wezterm` | `modules/programs/wezterm.nix` |
| `karabiner-elements` | `modules/apps/karabiner.nix` |
| `shottr` | `modules/apps/shottr.nix` |
| `flashspace` | `modules/apps/flashspace.nix` |
| `brave-browser`, `google-chrome`, `google-chrome@beta` | `modules/apps/browsers.nix` |
| `bruno`, `mockoon` | `modules/apps/api-tools.nix` |
| `rectangle-pro`, `homerow`, `hammerspoon`, `jordanbaird-ice` | `modules/apps/window-tools.nix` |
| `iina`, `vlc` | `modules/apps/media.nix` |
| `appcleaner`, `keka`, `rocket`, `raycast`, `discord`, `zoom`, `obsidian`, `cmux`, `visual-studio-code`, `orbstack` | `modules/apps/desktop.nix` |
| all 16 `masApps` | `modules/apps/mas.nix` |

Example of a topic file that owns its cask:

```nix
# modules/apps/karabiner.nix
{ inputs, ... }:
{
  flake.modules.darwin.base.homebrew.casks = [ "karabiner-elements" ];

  flake.modules.homeManager.base = { lib, ... }: {
    home.file.".config/karabiner/karabiner.json" = {
      source = inputs.self + "/dotfiles/karabiner/karabiner.json";
      onChange = ''echo "Karabiner config changed"'';
    };
    home.activation.configureKarabiner =
      lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
        # ... unchanged ...
      '';
  };
}
```

One app. One file. System side and user side together.
This is the point of the whole change.

### 4.4 Straight moves (no split needed)

| old | new | slot |
|---|---|---|
| `common/nix-packages.nix` | `modules/darwin/packages.nix` | `darwin.base` |
| `common/system-defaults.nix` | `modules/darwin/system-defaults.nix` | `darwin.base` |
| `common/programs/atuin.nix` | `modules/programs/atuin.nix` | `homeManager.base` |
| `common/programs/fastfetch.nix` | `modules/programs/fastfetch.nix` | `homeManager.base` |
| `common/programs/mise.nix` | `modules/programs/mise.nix` | `homeManager.base` |
| `common/programs/fish/default.nix` | `modules/programs/fish.nix` | `homeManager.base` |
| `common/programs/fish/abbreviations.nix` | `modules/programs/fish-abbr.nix` | `homeManager.base` |
| `common/programs/fish/functions.nix` | `modules/programs/fish-functions.nix` | `homeManager.base` |
| `common/programs/fish/git-functions.nix` | `modules/programs/fish-git-functions.nix` | `homeManager.base` |
| `common/programs/default.nix` | **deleted** | - |
| `shells/default.nix` | **deleted** | - |
| `lib/mkDarwinConfig.nix` | **deleted** | - |

The 3 deleted files only held import lists. `import-tree` does that job now.

### 4.5 Hosts and profiles are folded into one file each

`modules/hosts/mbp.nix` replaces 4 old files:
`hosts/mbp/default.nix`, `system-defaults.nix`, `homebrew.nix`, `home-manager.nix`.

```nix
{ inputs, config, ... }:
{
  flake.darwinConfigurations.mbp = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      config.flake.modules.darwin.base
      config.flake.modules.darwin.mbp
    ];
  };

  flake.modules.darwin.mbp = {
    networking.hostName = "mbp";
    system.defaults.dock.tilesize = 65;
    system.defaults.controlcenter.BatteryShowPercentage = true;
    homebrew.casks = [ "batfi" ];
    home-manager.users.milhamh95.imports = [
      config.flake.modules.homeManager.base
      config.flake.modules.homeManager.mbp
    ];
  };

  flake.modules.homeManager.mbp = {
    programs.fish.shellAbbrs.nixmbp =
      "sudo darwin-rebuild switch --flake .#mbp";
    # flashspace + kickapp dotfiles -> see modules/apps/flashspace.nix
  };
}
```

`modules/hosts/mac-desktop.nix` is the same shape, plus:

```nix
    imports = [ config.flake.modules.darwin.work ];
    ...
    home-manager.users.milhamh95.imports = [
      config.flake.modules.homeManager.base
      config.flake.modules.homeManager.work
      config.flake.modules.homeManager.mac-desktop
    ];
```

`modules/profiles/work.nix` replaces the 3 files under `profiles/work/`:

```nix
{ inputs, lib, ... }:
{
  flake.modules.darwin.work = {
    homebrew.casks = [ "bloom" "tableplus" ];
    system.defaults.dock.persistent-apps =
      lib.mkBefore [ { app = "/Applications/Bloom.app"; } ];
  };

  flake.modules.homeManager.work = { lib, ... }: {
    programs.fish.shellAbbrs.work = "cd $HOME/work";
    home.activation.configureWorkFolder = lib.hm.dag.entryAfter
      [ "writeBoundary" ] '' ... '';
    home.file.".config/flashspace/settings.json".source =
      inputs.self + "/dotfiles/work/flashspace/settings.json";
    home.file.".config/kickapp/config.json".source =
      inputs.self + "/dotfiles/work/kickapp/config.json";
  };
}
```

### 4.6 Dev shells

Old `shells/*.nix` take `{ pkgs }` and are imported by hand.
New files use `perSystem`:

```nix
# modules/dev/postgres.nix
{
  perSystem = { pkgs, ... }: {
    devShells.postgres = pkgs.mkShell { /* body of shells/postgres.nix */ };
  };
}
```

| old | new |
|---|---|
| `shells/postgres.nix` + `dev/postgres.nix` | `modules/dev/postgres.nix` |
| `shells/redis.nix` + `dev/redis.nix` | `modules/dev/redis.nix` |
| `shells/sops.nix` | `modules/dev/sops.nix` |
| `shells/default.nix` | `modules/dev/default-shell.nix` |

Note: `shells/postgres.nix` and `dev/postgres.nix` overlap heavily.
Check both before you merge. Same for redis.

---

## 5. Dotfiles: the highest risk

Today there are 5 separate `dotfiles/` folders:

```
dotfiles/                       (not referenced by any .nix - manual backups)
common/dotfiles/
hosts/mbp/dotfiles/
hosts/mac-desktop/dotfiles/
profiles/work/dotfiles/
```

Every `source = ./dotfiles/...` breaks the moment its `.nix` file moves.

**Fix: one folder at the repo root, addressed from the flake root.**

```
dotfiles/
  atuin/  git/  karabiner/  kickapp/  ssh/  wezterm/   (from common/)
  mbp/         flashspace/ kickapp/                    (from hosts/mbp/)
  mac-desktop/ flashspace/ switor/                     (from hosts/mac-desktop/)
  work/        flashspace/ kickapp/                    (from profiles/work/)
  manual/      better-mouse/ bettertouchtool/ ...      (the unreferenced ones)
```

In every module, write:

```nix
source = inputs.self + "/dotfiles/wezterm/wezterm.lua";
```

not

```nix
source = ./dotfiles/wezterm/wezterm.lua;
```

`inputs.self` is the flake root. It never changes when a file moves.

Check for leftovers with: `grep -rn '\./dotfiles' modules/`

---

## 6. Order of work

| # | phase | time | output |
|---|---|---|---|
| 1 | New `flake.nix` + `modules/meta/*` + 2 host files | 45 min | builds, but empty config |
| 2 | Straight moves (4.4) + hosts/profiles (4.5) | 60 min | full config, files just moved |
| 3 | Dotfiles to root, switch to `inputs.self` (5) | 30 min | paths safe |
| 4 | Split `common/home-manager.nix` (4.2) | 90 min | one topic per file |
| 5 | Split homebrew by app (4.3) | 45 min | brew separated |
| 6 | Dev shells (4.6) + delete old dirs + docs | 30 min | clean repo |

Total: about 5 hours.

Stop after phase 3 and you already have a working dendritic repo.
Phases 4 and 5 can happen one file at a time, later.

---

## 7. Safety check

Before phase 1:

```
nix build .#darwinConfigurations.mbp.system --no-link --print-out-paths > /tmp/before-mbp.txt
nix build .#darwinConfigurations.mac-desktop.system --no-link --print-out-paths > /tmp/before-md.txt
```

After phase 6, run the same commands. Same store path = perfect migration.
Different path = run `nix store diff-closures /tmp/before-mbp.txt <new>` and
read what changed.

Commit after every phase. Each phase must build.

---

## 8. Things to watch

1. `flake.modules.<class>.<name>` needs a recent `flake-parts`. Run
   `nix flake update flake-parts` first.
2. The home-manager class name is `homeManager`, not `home-manager`.
3. `common/home-manager.nix` line 3 has `enableSecrets = !(builtins.pathExists ../secrets/.skip)`.
   That relative path must become `inputs.self + "/secrets/.skip"`.
4. `hosts/mac-desktop/home-manager.nix` copies `Switor.app` from
   `./dotfiles/switor/Switor.app`. That is a big binary path. Test it.
5. `Makefile` and `scripts/*.sh` may name old paths. Grep them at phase 6.
