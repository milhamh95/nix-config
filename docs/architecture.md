# Architecture

## How Layers Work

Configuration is built from layers that **merge together** — each machine opts into the layers it needs:

```mermaid
block-beta
    columns 2
    lbl4["Host"]:1
    block:layer4["hosts/{machine}/"]:1
        l4["machine-specific apps & system defaults"]
    end
    lbl3["Alami Profile"]:1
    block:layer3["profiles/alami/"]:1
        l3["slack, claude-code, pritunl, alami SSH, sdkman"]
    end
    lbl2["Work Profile"]:1
    block:layer2["profiles/work/"]:1
        l2["bloom, tableplus, work folder"]
    end
    lbl1["Common"]:1
    block:layer1["common/"]:1
        l1["browsers, media, fonts, karabiner, raycast, git, mas apps"]
    end

    style lbl1 fill:#74c7ec,color:#1e1e2e
    style lbl2 fill:#a18072,color:#1e1e2e
    style lbl3 fill:#f5a97f,color:#1e1e2e
    style lbl4 fill:#f38ba8,color:#1e1e2e
    style layer1 fill:#74c7ec,color:#1e1e2e
    style layer2 fill:#a18072,color:#1e1e2e
    style layer3 fill:#f5a97f,color:#1e1e2e
    style layer4 fill:#f38ba8,color:#1e1e2e
    style l1 fill:#74c7ec,color:#1e1e2e,stroke:#74c7ec
    style l2 fill:#a18072,color:#1e1e2e,stroke:#a18072
    style l3 fill:#f5a97f,color:#1e1e2e,stroke:#f5a97f
    style l4 fill:#f38ba8,color:#1e1e2e,stroke:#f38ba8
```

| Color | Layer | Applied to |
|---|---|---|
| 🔷 Cyan | `common/` | All machines |
| 🟤 Brown | `profiles/work/` | Machines used for work |
| 🟠 Peach | `profiles/alami/` | Machines for Alami job |
| 🔴 Pink | `hosts/{machine}/` | This specific machine only |

Defined in `flake.nix`:

```nix
"mac-desktop" = { profiles = [ "work" "alami" ]; };
"alami-mbp"   = { profiles = [ "work" "alami" ]; };
"mbp"         = { profiles = [];                 };  # minimal
```

---

## Directory Structure

```
nix-config/
├── flake.nix                       # Entry point — defines hosts + profiles
├── Makefile                        # Build commands
│
├── common/                         # Applied to ALL machines
│   ├── homebrew.nix                #   casks, brews, mas apps (18 App Store apps)
│   ├── nix-packages.nix            #   CLI tools + nerd fonts
│   ├── home-manager.nix            #   SSH, karabiner, bat, ghostty, BetterAudio, Recordly
│   ├── system-defaults.nix         #   macOS settings (dock, finder, keyboard)
│   └── programs/                   #   shell & tool configs
│       ├── fish/                   #     fish shell functions & abbreviations
│       ├── atuin.nix               #     shell history (Catppuccin theme)
│       └── fastfetch.nix           #     system info display
│
├── profiles/                       # Opt-in feature sets
│   ├── work/                       #   Generic work setup
│   │   ├── homebrew.nix            #     bloom, tableplus
│   │   ├── home-manager.nix        #     work folder setup
│   │   └── system-defaults.nix     #     Bloom in dock
│   └── alami/                      #   Alami job-specific
│       ├── homebrew.nix            #     slack, claude-code, pritunl, windsurf, rtk...
│       ├── nix-packages.nix        #     sftpgo, zstd
│       ├── home-manager.nix        #     alami SSH, sdkman, sftpgo config
│       └── fish/                   #     alami-specific functions & abbreviations
│
├── hosts/                          # Per-machine unique config
│   ├── mac-desktop/                #   bettermouse, bettertouchtool, betterdisplay, SoundSource, Switor
│   ├── mbp/                        #   batfi
│   └── alami-mbp/                  #   batfi
│
├── shells/                         # nix develop environments
│   ├── postgres.nix                #   PostgreSQL 17 with helper CLIs
│   ├── redis.nix                   #   Redis with port selection
│   └── sops.nix                    #   Age/SOPS secrets tooling
│
├── scripts/                        # Bootstrap scripts
│   ├── setup-nix.sh                #   Xcode + Nix + Homebrew
│   ├── install-desktop.sh
│   ├── install-mbp.sh
│   └── install-alami.sh
│
├── secrets/                        # Encrypted SSH keys (sops-nix + age)
│
└── docs/                           # Documentation
```

---

## What's in Common

Everything in `common/` is installed on **all three machines**.

<details>
<summary>Nix packages (CLI tools)</summary>

age, atuin, bat, curl, delta, fastfetch, fd, fzf, git, lazygit, lsd, openssl, ripgrep, sops, vim, wget, yarn

Fish plugins: tide, sponge, z, done, forgit, colored-man-pages, sdkman-for-fish

Fonts: JetBrains Mono, Hack, BlexMono, iM Writing (all Nerd Font variants)

</details>

<details>
<summary>Homebrew casks (GUI apps)</summary>

appcleaner, brave-browser, bruno, cmux, discord, flashspace, ghostty, google-chrome, google-chrome@beta, hammerspoon, homerow, iina, jordanbaird-ice, karabiner-elements, keka, mockoon, obsidian, orbstack, raycast, rectangle-pro, rocket, shottr, visual-studio-code, vlc, wezterm, zoom

</details>

<details>
<summary>Mac App Store apps (mas)</summary>

Amphetamine, BarMarks, DaisyDisk, ExcalidrawZ, Fantastical, Flow, Folder Quick Look, iStat Menus, LilyView, Numbers, OpenIn, PastePal, PDF Expert, Presentify, rcmd, SnippetsLab, Spark, Spokenly

</details>

<details>
<summary>Apps installed from GitHub Releases (auto-updated)</summary>

These are downloaded and installed via activation scripts. On every `darwin-rebuild`, the script queries the GitHub API for the latest stable release and only downloads if a newer version is available.

- **BetterAudio** — [rokartur/BetterAudio](https://github.com/rokartur/BetterAudio/releases)
- **Recordly** — [webadderallorg/Recordly](https://github.com/webadderallorg/Recordly/releases)

</details>

---

## Per-Machine Config Flow

### mac-desktop — `profiles = ["work", "alami"]`

```mermaid
flowchart LR
    subgraph common["common/"]
        c_pkg["packages: git, bat, fzf, delta, lazygit, fonts..."]
        c_app["apps: chrome, brave, ghostty, raycast, orbstack..."]
        c_mas["mas: Amphetamine, Flow, iStat Menus, Spark + 14 more"]
        c_gh["github releases: BetterAudio, Recordly"]
        c_cfg["config: karabiner, SSH, bat theme, fish, atuin"]
    end

    subgraph work["profiles/work/"]
        w["bloom, tableplus, work folder"]
    end

    subgraph alami["profiles/alami/"]
        a["slack, claude-code, pritunl, windsurf, alami SSH, sdkman"]
    end

    subgraph host["hosts/mac-desktop/"]
        h["bettermouse, bettertouchtool, betterdisplay, SoundSource, Switor"]
        h_sys["dock size 65"]
    end

    result["mac-desktop"]

    common --> result
    work --> result
    alami --> result
    host --> result

    style common fill:#74c7ec,color:#1e1e2e
    style work fill:#a18072,color:#1e1e2e
    style alami fill:#f5a97f,color:#1e1e2e
    style host fill:#f38ba8,color:#1e1e2e
```

### alami-mbp — `profiles = ["work", "alami"]`

Same profiles as mac-desktop, different host config:

```mermaid
flowchart LR
    subgraph common["common/"]
        c["packages + apps + mas apps + github releases + config"]
    end

    subgraph work["profiles/work/"]
        w["bloom, tableplus, work folder"]
    end

    subgraph alami["profiles/alami/"]
        a["slack, claude-code, pritunl, windsurf, alami SSH, sdkman"]
    end

    subgraph host["hosts/alami-mbp/"]
        h["batfi"]
        h_sys["dock size 50, battery %"]
    end

    result["alami-mbp"]

    common --> result
    work --> result
    alami --> result
    host --> result

    style common fill:#74c7ec,color:#1e1e2e
    style work fill:#a18072,color:#1e1e2e
    style alami fill:#f5a97f,color:#1e1e2e
    style host fill:#f38ba8,color:#1e1e2e
```

### mbp — `profiles = []`

Minimal — only common + host:

```mermaid
flowchart LR
    subgraph common["common/"]
        c["packages + apps + mas apps + github releases + config"]
    end

    subgraph host["hosts/mbp/"]
        h["batfi"]
        h_sys["dock size 50, battery %"]
    end

    result["mbp (minimal)"]

    common --> result
    host --> result

    style common fill:#74c7ec,color:#1e1e2e
    style host fill:#f38ba8,color:#1e1e2e
```

---

## Installation Flow

```mermaid
flowchart LR
    s1["1. Xcode CLI Tools"] --> s2["2. Install Nix"] --> s3["3. Install Homebrew"] --> s4["4. Apply nix-darwin"]
```

Run `make install-desktop`, `make install-mbp`, or `make install-alami` to execute all steps.
