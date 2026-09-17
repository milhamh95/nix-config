# The cask is shared. Per-host settings.json / profiles.json live on each
# host's own file (modules/hosts/*.nix) since they genuinely differ per
# machine.
{
  den.aspects.flashspace.darwin.homebrew.casks = [ "flashspace" ];
}
