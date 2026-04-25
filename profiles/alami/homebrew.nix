# profiles/alami/homebrew.nix - Alami-specific Homebrew apps
{ config, lib, pkgs, ... }:

{
  homebrew = {
    casks = [
      "claude-code"
      "conductor"
      "github"
      "pritunl"
      "rewritebar"
      "slack"
      "windsurf"
      "wezterm"
    ];
  };
}
