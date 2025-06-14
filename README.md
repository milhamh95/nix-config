# Nix Config

This repository contains my personal Nix configuration to manage my system packages, dev environment, and dotfiles.

Notes:
> This is my first nix config, needs some improvement. If you want to see advance nix config, I recommend you to check out [github.com/r17x/universe](https://github.com/r17x/universe)

## To Do

- Solve issue [nix-darwin reinstalls masApps upon every darwin-rebuild switch command](https://github.com/nix-darwin/nix-darwin/issues/1323)
- Refactor config, split into smaller files.
- Put private key in this repo (need to find a way to encrypt and decrypt the key automatically)
- Use [nixos-unified](https://nixos-unified.org/index.html) to unitfy nix-darwin + home-manager in a single flake.

## Prerequisite

### 1. Login to mac apple store

- Please login to mac apple store first.
- To install package using mas

### 2. Add Full Disk Access to Terminal

- To change mac system default `universal` setting, need to add your Terminal (`Terminal.app` / `Ghostty` / `iTerm2` / `WezTerm`) to `Full Disk Access` config
- You can do this by going to `System Settings > Security & Privacy > Privacy > Full Disk Access`

NOTE:

## Installation Using Script

1. In `$HOME` folder, create `.nix` folder using terminal

```sh
mkdir ~/.nix
```

2. Download nix-config repo to `.nix` folder
3. Open Terminal, open `/.nix/nix-config` folder

```sh
cd ~/.nix/nix-config
```

4. Add executable permission to install script

```sh
chmod +x install.sh
```

5. Run install script

```sh
./install.sh
```

Please make sure to not install `Determinate` package, [we only need](https://github.com/nix-darwin/nix-darwin/issues/1349)`Nix`

![Determinate Package](https://i.postimg.cc/RV1VDYcT/417102248-d01c1e14-7d49-443b-b171-b08e9fe5746c.png)

Press `n` to skip installing `Determinate` package.

6. Choose your mac config

In the terminal, it will appear `Choose your nix-darwin configuration:` message.
- Type `1` for `mac-desktop` -> Mac Desktop
- Type `2` for `mbp` -> MacBook Pro

At the end of installation script, it will run the proper nix config

```sh
# Install for mac desktop
nix run nix-darwin -- switch --flake .#mac-desktop

# Install for macbook pro
nix run nix-darwin -- switch --flake .#mbp
```

## Rebuild config

After updating the configuration, run the following command:

```sh
Based on: https://github.com/nix-darwin/nix-darwin/issues/1457
sudo darwin-rebuild switch --flake .#mac-desktop

sudo darwin-rebuild switch --flake .#mbp
```

## Update Flake

To update all inputs and depenencies, run:

```sh
nix flake update
```

## Clean Up Leftover

We need to clean up leftover apps after recreate the system.

To see all these generations of systems

```sh
darwin-rebuild --list-generations
```

To clean up leftover generations older than 7 days

```sh
nix-collect-garbage --delete-older-than 7d
sudo nix-collect-garbage --delete-older-than 7d
```

To clean up all leftover generations

```sh
nix-collect-garbage -d
sudo nix-collect-garbage -d
```

## Reference

Special thanks to these nix configs that helped me to build my own nix config:

- [github.com/r17x/universe](https://github.com/r17x/universe)
- [github.com/torgeir/nix-darwin](https://github.com/torgeir/nix-darwin)
- [github.com/linkarzu/dotfiles-latest](https://github.com/linkarzu/dotfiles-latest)
