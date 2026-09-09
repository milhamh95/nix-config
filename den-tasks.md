# Den migration — task checklist

**One task at a time. Tick it. Run the check. Move on.**

If a check fails, the cause is the task you just did. Nothing else changed.

---

## The 3 checks

Learn these. You will run them constantly.

```bash
# FAST (seconds) — does it evaluate? Run after EVERY task.
alias ck='nix eval .#darwinConfigurations.mbp.system.drvPath --raw >/dev/null && echo OK'

# FULL (minutes) — does it build? Run at each PHASE end.
nix build .#darwinConfigurations.mbp.system --no-link --print-out-paths

# TRUTH (minutes) — is it the SAME system as before? Run at each PHASE end.
diff <(cat /tmp/before-mbp.txt) <(nix build .#darwinConfigurations.mbp.system --no-link --print-out-paths)
```

**Why the truth check matters:** den can silently drop config (see
`den-nix.md` section 9.1). No error. The hash is the only proof.

---

## Progress

```
PHASE 0  Safety net          [ ]  4 tasks   ~15 min   YOU
PHASE 1  Skeleton builds     [ ]  7 tasks   ~45 min   ME
PHASE 2  Dotfiles safe       [ ]  3 tasks   ~20 min   ME
PHASE 3  Straight moves      [ ] 13 tasks   ~60 min   ME
PHASE 4  Homebrew split      [ ] 10 tasks   ~40 min   ME
PHASE 5  The 429-line monster[ ] 14 tasks   ~90 min   ME
PHASE 6  Layers + plugs      [ ]  5 tasks   ~30 min   ME
PHASE 7  Dev shells          [ ]  5 tasks   ~20 min   ME
PHASE 8  Cleanup             [ ]  5 tasks   ~30 min   ME
PHASE 9  Real machines       [ ]  5 tasks   ~3-4 h    YOU
```

**You can stop after any phase.** `main` stays untouched the whole time.

---

## PHASE 0 — Safety net · YOU · ~15 min

Do this before anything. It is the thing that lets you undo.

- [ ] **0.1** Snapshot mbp
  ```bash
  nix build .#darwinConfigurations.mbp.system --no-link --print-out-paths > /tmp/before-mbp.txt
  ```
- [ ] **0.2** Snapshot mac-desktop
  ```bash
  nix build .#darwinConfigurations.mac-desktop.system --no-link --print-out-paths > /tmp/before-md.txt
  ```
- [ ] **0.3** Copy both somewhere permanent (`/tmp` gets wiped)
  ```bash
  cp /tmp/before-*.txt ~/Documents/
  ```
- [ ] **0.4** New branch
  ```bash
  git checkout -b feat/den && git status
  ```

### ✅ CHECKPOINT 0

```bash
cat /tmp/before-mbp.txt /tmp/before-md.txt   # two /nix/store paths
git branch --show-current                    # feat/den
```

**Both files have a path? On the branch? Go to Phase 1.**

---

## PHASE 1 — Skeleton that builds · ME · ~45 min

Goal: a den config that **builds** but has almost nothing in it. Proves the
wiring works before we move any real config.

- [ ] **1.1** `mkdir -p modules/{users,layers,hosts,features,dev}`
- [ ] **1.2** Write `flake.nix` — den + import-tree + flake-file inputs
- [ ] **1.3** Write `modules/den.nix` — import `den.flakeModule`, set user class
- [ ] **1.4** Write `modules/hosts.nix` — 2 hosts, 1 user each

  **Check:** `nix eval .#darwinConfigurations --apply builtins.attrNames`
  → must print `[ "mac-desktop" "mbp" ]`
- [ ] **1.5** Write `modules/defaults.nix` — stateVersion, allowUnfree, fish overlay, experimental-features
- [ ] **1.6** Write `modules/users/milhamh95.nix` — batteries + `uid` + `knownUsers`

  **Check:** `nix eval .#darwinConfigurations.mbp.config.system.primaryUser`
  → must print `"milhamh95"` (proves `primary-user` battery fired)
- [ ] **1.7** Write `modules/hosts/mbp.nix` + `modules/hosts/mac-desktop.nix` — hostname, dock size

### ✅ CHECKPOINT 1

```bash
nix build .#darwinConfigurations.mbp.system         --no-link
nix build .#darwinConfigurations.mac-desktop.system --no-link

# prove the user actually exists
nix eval .#darwinConfigurations.mbp.config.users.users.milhamh95.home
# -> "/Users/milhamh95"

# prove HM is wired
nix eval .#darwinConfigurations.mbp.config.home-manager.users --apply builtins.attrNames
# -> [ "milhamh95" ]
```

**Hash will NOT match yet.** That is correct — the config is nearly empty.

**Both build? Stop and look at the 7 files.** This is the whole den model.
If it does not click now, it will not click later. Say so and we adjust.

---

## PHASE 2 — Dotfiles safe · ME · ~20 min

Highest-risk mechanical step. Every `./dotfiles/...` path breaks when a file
moves. Fix it once, up front.

- [ ] **2.1** Move all 5 dotfiles folders into one root `dotfiles/`
  ```
  common/dotfiles/*        -> dotfiles/
  hosts/mbp/dotfiles/*     -> dotfiles/mbp/
  hosts/mac-desktop/*      -> dotfiles/mac-desktop/
  profiles/work/dotfiles/* -> dotfiles/work/
  dotfiles/ (existing)     -> dotfiles/manual/
  ```
- [ ] **2.2** `git add dotfiles/` — nix cannot see untracked files
- [ ] **2.3** Confirm nothing references the old paths

### ✅ CHECKPOINT 2

```bash
grep -rn '\./dotfiles' modules/     # must print NOTHING
ls dotfiles/                        # atuin git karabiner kickapp ssh wezterm mbp mac-desktop work manual
git status --short | head           # dotfiles staged
```

**Rule from here on:** always `inputs.self + "/dotfiles/..."`, never `./dotfiles/...`.

---

## PHASE 3 — Straight moves · ME · ~60 min

Low risk. These files barely change — just wrapped in an aspect.

One task = one file = one `ck`.

- [ ] **3.1** `features/nix-packages.nix` ← `common/nix-packages.nix`
- [ ] **3.2** `features/system-defaults.nix` ← `common/system-defaults.nix`
- [ ] **3.3** `features/fish.nix` ← `common/programs/fish/default.nix`
- [ ] **3.4** `features/fish-abbr.nix` ← `fish/abbreviations.nix`
- [ ] **3.5** `features/fish-functions.nix` ← `fish/functions.nix`
- [ ] **3.6** `features/fish-git-functions.nix` ← `fish/git-functions.nix`
- [ ] **3.7** `features/atuin.nix` ← `common/programs/atuin.nix`
- [ ] **3.8** `features/fastfetch.nix` ← `common/programs/fastfetch.nix`
- [ ] **3.9** `features/mise.nix` ← `common/programs/mise.nix`
- [ ] **3.10** `features/ghostty.nix` ← `home-manager.nix:317-347`
- [ ] **3.11** `features/bat.nix` ← `home-manager.nix:368-379`
- [ ] **3.12** `features/wezterm.nix` ← `home-manager.nix:410-415`
- [ ] **3.13** `layers/common.nix` — includes all of the above

### ✅ CHECKPOINT 3

```bash
# prove HM content REACHED the user (the silent-inert trap)
nix eval .#darwinConfigurations.mbp.config.home-manager.users.milhamh95.programs.fish.enable
# -> true

nix eval .#darwinConfigurations.mbp.config.home-manager.users.milhamh95.programs.bat.enable
# -> true

nix build .#darwinConfigurations.mbp.system --no-link
```

**If `fish.enable` is `false`, stop.** That is trap 9.1. Something landed on
a host aspect instead of the user aspect.

---

## PHASE 4 — Homebrew split · ME · ~40 min

The engine stays in one file. Each app takes its own cask.

- [ ] **4.1** `features/homebrew-engine.nix` — `enable`, `taps`, `shellInit`, `onActivation`, brews `bash`/`mas`/`mole`
- [ ] **4.2** `features/git.nix` — brew `gh` + `programs.git` + delta + `.gitignore` + theme
- [ ] **4.3** `features/ghostty.nix` — add cask `ghostty`
- [ ] **4.4** `features/wezterm.nix` — add cask `wezterm`
- [ ] **4.5** `features/browsers.nix` — brave, chrome, chrome@beta
- [ ] **4.6** `features/api-tools.nix` — bruno, mockoon
- [ ] **4.7** `features/window-tools.nix` — rectangle-pro, homerow, hammerspoon, jordanbaird-ice
- [ ] **4.8** `features/media.nix` — iina, vlc
- [ ] **4.9** `features/desktop.nix` — appcleaner, keka, rocket, raycast, discord, zoom, obsidian, cmux, vscode, orbstack
- [ ] **4.10** `features/mas.nix` — all 16 masApps

### ✅ CHECKPOINT 4

```bash
# THE BIG ONE: casks are on the USER aspect, must flow UP to the host
nix eval .#darwinConfigurations.mbp.config.homebrew.casks --apply builtins.length
# -> should be ~26, NOT 0

# compare against today, exactly
nix eval .#darwinConfigurations.mbp.config.homebrew.casks --json | jq -r '.[]' | sort > /tmp/casks-new.txt
git show main:common/homebrew.nix | grep -oE '"[a-z0-9@.-]+"' | tr -d '"' | sort > /tmp/casks-old.txt
diff /tmp/casks-old.txt /tmp/casks-new.txt
```

**`length` is 0? Stop.** The user→host flow is not working. Do not continue.

---

## PHASE 5 — The 429-line monster · ME · ~90 min

Biggest phase. `common/home-manager.nix` becomes ~14 files.

**Activation bash is copied byte-for-byte. It does not get rewritten.**

- [ ] **5.1** `features/sops.nix` — secrets + fix `../secrets/.skip` → `inputs.self + "/secrets/.skip"`
- [ ] **5.2** `features/activation-fix.nix` — `fixReadlinkM`
- [ ] **5.3** `features/fish.nix` — add `configureTide` activation
- [ ] **5.4** `features/shottr.nix` — cask + `configureShottr`
- [ ] **5.5** `features/recordly.nix` — `configureRecordly` + `installRecordly` (~85 lines bash)
- [ ] **5.6** `features/sdkman.nix` — `configureSdkman` + candidates (~40 lines bash)
- [ ] **5.7** `features/karabiner.nix` — cask + `karabiner.json` + `configureKarabiner`
- [ ] **5.8** `features/better-audio.nix` — `installBetterAudio` (~79 lines bash)
- [ ] **5.9** `features/flashspace.nix` — cask + per-host settings
- [ ] **5.10** `features/kickapp.nix` — `Applications/KickApp.app`
- [ ] **5.11** `features/ssh.nix` — `programs.ssh` + pubkey + `known_hosts`
- [ ] **5.12** `features/atuin.nix` — add theme file
- [ ] **5.13** `modules/defaults.nix` — add `home.sessionPath`, `xdg.enable`
- [ ] **5.14** Update `layers/common.nix` with every new aspect

### ✅ CHECKPOINT 5

```bash
# count activation scripts — must match today
nix eval .#darwinConfigurations.mbp.config.home-manager.users.milhamh95.home.activation \
  --apply 'a: builtins.length (builtins.attrNames a)'

# same number on main?
git stash && nix eval .#darwinConfigurations.mbp.config.home-manager.users.milhamh95.home.activation \
  --apply 'a: builtins.length (builtins.attrNames a)' ; git stash pop

# count managed files
nix eval .#darwinConfigurations.mbp.config.home-manager.users.milhamh95.home.file \
  --apply 'f: builtins.attrNames f'
# -> must list all 7: karabiner.json, .gitignore, delta theme, atuin theme,
#    ssh pubkey, known_hosts, KickApp.app

nix build .#darwinConfigurations.mbp.system --no-link
```

**A missing activation script or `home.file` entry = silent drop. Find it now.**

---

## PHASE 6 — Layers and plugs · ME · ~30 min

- [ ] **6.1** `layers/work.nix` — bloom, tableplus, dock, `$HOME/work`, flashspace + kickapp work dotfiles
- [ ] **6.2** `layers/personal.nix` — `configurePersonalFolder`
- [ ] **6.3** `hosts/mac-desktop.nix` — add `provides.to-users.includes = [ den.aspects.work ];`
- [ ] **6.4** `hosts/mbp.nix` — add `provides.to-users.includes = [ den.aspects.personal ];`
- [ ] **6.5** `hosts/mac-desktop.nix` — Switor.app + host dotfiles

### ✅ CHECKPOINT 6

```bash
# work ON for mac-desktop
nix eval .#darwinConfigurations.mac-desktop.config.homebrew.casks --apply 'c: builtins.elem "bloom" c'
# -> true

# work OFF for mbp
nix eval .#darwinConfigurations.mbp.config.homebrew.casks --apply 'c: builtins.elem "bloom" c'
# -> false

# work's HM half reached the user (the to-users plug)
nix eval .#darwinConfigurations.mac-desktop.config.home-manager.users.milhamh95.programs.fish.shellAbbrs.work
# -> "cd $HOME/work"
```

**Third check returns an error or null? The plug is not delivering. Trap 9.1.**

---

## PHASE 7 — Dev shells · ME · ~20 min

- [ ] **7.1** `dev/postgres.nix` — merge `shells/postgres.nix` + `dev/postgres.nix` (they overlap — read both)
- [ ] **7.2** `dev/redis.nix` — same merge
- [ ] **7.3** `dev/sops.nix` ← `shells/sops.nix`
- [ ] **7.4** `dev/default-shell.nix` ← `shells/default.nix`
- [ ] **7.5** Delete `shells/` and `dev/` old dirs

### ✅ CHECKPOINT 7

```bash
nix flake show 2>/dev/null | grep -A5 devShells
# -> default, postgres, redis, sops

nix develop .#postgres --command echo OK
```

---

## PHASE 8 — Cleanup and the truth check · ME · ~30 min

- [ ] **8.1** Delete `common/ hosts/ lib/ profiles/ shells/ dev/`
- [ ] **8.2** `grep -rn 'common/\|profiles/\|mkDarwinConfig' Makefile scripts/` — fix hits
- [ ] **8.3** Update `README.md` with the new tree
- [ ] **8.4** `nix flake check`
- [ ] **8.5** Final hash compare

### ✅ CHECKPOINT 8 — THE BIG ONE

```bash
nix build .#darwinConfigurations.mbp.system         --no-link --print-out-paths > /tmp/after-mbp.txt
nix build .#darwinConfigurations.mac-desktop.system --no-link --print-out-paths > /tmp/after-md.txt

diff /tmp/before-mbp.txt /tmp/after-mbp.txt && echo "MBP IDENTICAL ✅"
diff /tmp/before-md.txt  /tmp/after-md.txt  && echo "DESKTOP IDENTICAL ✅"
```

**Identical hash = perfect migration. Nothing was lost.**

**Different?** Not automatically bad — read what changed:

```bash
nix store diff-closures $(cat /tmp/before-mbp.txt) $(cat /tmp/after-mbp.txt)
```

Expected harmless drift: `system.configurationRevision`, HM internals.
**Not harmless:** a missing package, a missing cask, a dropped file.

---

## PHASE 9 — Real machines · YOU · ~3–4 h

**Only I cannot do this part.** Needs sudo and real hardware.

- [ ] **9.1** Dry run on mbp
  ```bash
  sudo darwin-rebuild build --flake .#mbp
  ```
- [ ] **9.2** Switch mbp
  ```bash
  sudo darwin-rebuild switch --flake .#mbp
  ```
- [ ] **9.3** Verify by hand on mbp
  - fish prompt (tide) still configured
  - karabiner still remaps keys
  - `~/personal` exists
  - `gh`, `bat`, `atuin` work
  - Recordly / BetterAudio / SDKMAN did not re-download
- [ ] **9.4** Switch mac-desktop, verify work apps
  - Bloom + TablePlus present
  - `~/work` exists
  - `work` abbreviation works in fish
- [ ] **9.5** Merge to `main`

### ✅ CHECKPOINT 9

Both machines boot, both feel normal after a day of use.

### If a switch goes wrong

```bash
git checkout main
sudo darwin-rebuild switch --flake .#mbp
```

`main` was never touched. You are back in 2 minutes.

---

## Rules while we work

1. **One task, then a check.** Never batch 5 tasks then check.
2. **A check fails → the last task caused it.** Nothing else moved.
3. **Commit after every phase.** `git commit -am "den: phase N"`
4. **Never `git add -A`.** Nix needs new `.nix` files staged, but stage them by name.
5. **Stop whenever you want.** `main` still boots.

---

## Start here

**Phase 0 is yours. 4 tasks, ~15 minutes. Run this now:**

```bash
nix build .#darwinConfigurations.mbp.system         --no-link --print-out-paths > /tmp/before-mbp.txt
nix build .#darwinConfigurations.mac-desktop.system --no-link --print-out-paths > /tmp/before-md.txt
cp /tmp/before-*.txt ~/Documents/
git checkout -b feat/den
```

Paste me the two store paths and I start Phase 1.
