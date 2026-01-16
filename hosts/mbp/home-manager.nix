# hosts/mbp/home-manager.nix - MacBook Pro specific home-manager config
{ config, pkgs, lib, ... }:

{
  # Laptop-specific home file configurations
  home.file = {
    # Git config (host-specific due to username in paths)
    ".gitconfig" = {
      source = ../../app-config/hosts/mbp/git/.gitconfig;
      onChange = ''
        echo "Git config changed"
      '';
    };
    ".config/ghostty/config" = {
      source = ../../app-config/hosts/mbp/ghostty/config;
      onChange = ''
        echo "Ghostty config changed"
      '';
    };
    ".config/flashspace/profiles.json" = {
      source = ../../app-config/hosts/mbp/flashspace/profiles.json;
      onChange = ''
        echo "Flashspace profiles changed"
      '';
    };
    ".config/flashspace/settings.json" = {
      source = ../../app-config/hosts/mbp/flashspace/settings.json;
      onChange = ''
        echo "Flashspace settings changed"
      '';
    };
    ".wezterm.lua" = {
      source = ../../app-config/hosts/mbp/wezterm/wezterm.lua;
      onChange = ''
        echo "WezTerm config changed"
      '';
    };
    ".hammerspoon/home.toml" = {
      source = ../../app-config/hosts/mbp/hammerflow/home.toml;
      onChange = ''
        echo "Hammerspoon home config changed"
      '';
    };
    ".hammerspoon/init.lua" = {
      source = ../../app-config/hosts/mbp/hammerflow/init.lua;
      onChange = ''
        echo "Hammerspoon init config changed"
      '';
    };
  };
}
