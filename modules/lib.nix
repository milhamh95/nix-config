# Small helper to cut the repeated `source + onChange echo (+ optional
# force)` boilerplate on home.file entries that track one dotfile.
{ self, ... }:
{
  flake.lib.dotfile =
    {
      path,
      label,
      force ? false,
    }:
    {
      source = self + "/dotfiles/${path}";
      onChange = ''
        echo "${label} changed"
      '';
    }
    // (if force then { force = true; } else { });
}
