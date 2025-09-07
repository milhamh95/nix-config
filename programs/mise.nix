{ config, lib, pkgs, ... }:

{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {
      experimental = false;
      verbose = false;
      auto_install = true;
    };
  };

  # activation script to set up mise configuration
  home.activation.setupMise = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # enable corepack (pnpm, yarn, etc.)
    ${pkgs.mise}/bin/mise set MISE_NODE_COREPACK=true

    # disable warning about */.node-version files
    ${pkgs.mise}/bin/mise settings add idiomatic_version_file_enable_tools "[]"

    # set global tool versions (auto_install will handle installation)
    ${pkgs.mise}/bin/mise use --global node@latest
    ${pkgs.mise}/bin/mise use --global bun@latest
    ${pkgs.mise}/bin/mise use --global deno@latest
    ${pkgs.mise}/bin/mise use --global rust@latest
  '';
}