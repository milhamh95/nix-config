# Builder function: turns one host's data (from `hostConfigs` in flake.nix)
# into a real, buildable nix-darwin configuration.
{ nix-darwin, home-manager, inputs, mkBaseConfiguration, profileSystemModules, profileHomeModules }:

hostConfig:
let
  hostname = hostConfig.hostname;
  username = hostConfig.username;
  profiles = hostConfig.profiles or [];

  # Collect system-level modules from profiles
  extraSystemModules = builtins.concatMap
    (p: profileSystemModules.${p} or [])
    profiles;

  # Collect home-manager modules from profiles
  extraHomeModules = builtins.concatMap
    (p: profileHomeModules.${p} or [])
    profiles;
in
nix-darwin.lib.darwinSystem {
  modules = [
    # Base system configuration
    (mkBaseConfiguration { inherit username; })

    # Common modules (shared across all hosts)
    ../common/system-defaults.nix
    ../common/homebrew.nix

    # Profile modules (role-based, e.g. dev, work)
  ] ++ extraSystemModules ++ [

    # Host-specific modules
    ../hosts/${hostname}/default.nix
    ../hosts/${hostname}/system-defaults.nix
    ../hosts/${hostname}/homebrew.nix

    # Home-manager configuration
    home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users.${username} = { config, pkgs, lib, ... }: {
        imports = [
          inputs.sops-nix.homeManagerModules.sops
          ../common/home-manager.nix
        ] ++ extraHomeModules ++ [
          ../hosts/${hostname}/home-manager.nix
        ];
      };
      home-manager.backupFileExtension = "backup";
    }
  ];
}
