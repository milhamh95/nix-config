# Everything both identities (personal + future work) get. Written once.
{ den, ... }:
{
  den.aspects.common.includes = [
    den.aspects.nix-packages
    den.aspects.nix-gc
    den.aspects.system-defaults
    den.aspects.fish
    den.aspects.fish-abbr
    den.aspects.fish-functions
    den.aspects.fish-git-functions
    den.aspects.atuin
    den.aspects.fastfetch
    den.aspects.mise
    den.aspects.ghostty
    den.aspects.bat
    den.aspects.wezterm

    den.aspects.homebrew-engine
    den.aspects.git
    den.aspects.browsers
    den.aspects.api-tools
    den.aspects.window-tools
    den.aspects.media
    den.aspects.desktop
    den.aspects.mas

    den.aspects.sops
    den.aspects.activation-fix
    den.aspects.shottr
    den.aspects.recordly
    den.aspects.tinycast
    den.aspects.karabiner
    den.aspects.better-audio
    den.aspects.flashspace
    den.aspects.kickapp
    den.aspects.ssh
    den.aspects.personal-folder
  ];
}
