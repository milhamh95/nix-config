# Cleanup TODO

Files that are no longer referenced in nix config and can be deleted after verifying everything works.

## Bat files (replaced by `programs.bat`)

- [ ] `common/dotfiles/bat/config` — theme is now set in `programs.bat.config.theme`
- Note: `common/dotfiles/bat/themes/Catppuccin-Mocha.tmTheme` is still used by `programs.bat.themes.src` — do NOT delete

## Mise config (replaced by `programs.mise.globalConfig`)

- [ ] `common/dotfiles/mise/config.toml` — tools and settings now in `programs.mise.globalConfig` (common/programs/mise.nix)

## Ghostty config (replaced by `programs.ghostty`)

- [ ] `common/dotfiles/ghostty/config` — now managed by `programs.ghostty.settings` in common/home-manager.nix

## SSH config files (replaced by `programs.ssh`)

- [ ] `common/dotfiles/ssh/config` — now managed by `programs.ssh.matchBlocks` in common/home-manager.nix
- [ ] `profiles/alami/dotfiles/ssh/config` — now managed by `programs.ssh.matchBlocks` in profiles/alami/home-manager.nix
- Note: `common/dotfiles/ssh/id_github_personal.pub` and `profiles/alami/dotfiles/ssh/id_github_alami_group.pub` are still used by `home.file` — do NOT delete

## Git identity files (replaced by `programs.git`)

- [ ] `common/dotfiles/git/.gitconfig-personal` — identity is now in `programs.git.settings.user` (common/home-manager.nix)
- [ ] `profiles/alami/dotfiles/git/.gitconfig-alami-group` — identity is now inlined in `programs.git.includes` (profiles/alami/home-manager.nix)
