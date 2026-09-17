# Install apps using homebrew for consistent paths across machines.
# This makes it easier to map applications to FlashSpace.
# Each app's cask lives with its own aspect. This file owns only the engine.
{
  den.aspects.homebrew-engine.darwin =
    { config, lib, ... }:
    {
      environment.shellInit = lib.mkIf config.homebrew.enable ''
        eval "$(${config.homebrew.prefix}/bin/brew shellenv)"
      '';

      homebrew = {
        enable = true;
        taps = [ "stablyai/orca" ];

        brews = [
          "bash"
          "herdr"
          "mas"
          "mole"
          "opencode"
          "pi-coding-agent"
          "xcodegen"
        ];

        casks = [ "stablyai/orca/orca" ];

        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
        onActivation.cleanup = "uninstall";
      };
    };
}
