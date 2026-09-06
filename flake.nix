{
  description = "Nix Darwin Config for Mac";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # flake-parts for modular flake structure
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, sops-nix, flake-parts, ... }:
  let
    # Host configurations - define username and profiles per machine
    hostConfigs = {
      "mac-desktop" = {
        hostname = "mac-desktop";
        username = "milhamh95";
        profiles = [ "work" ];
      };
      "mbp" = {
        hostname = "mbp";
        username = "milhamh95";
        profiles = [ ];
      };
    };

    # Profile modules (system-level and home-manager-level)
    profileSystemModules = {
      "work" = [
        ./profiles/work/homebrew.nix
        ./profiles/work/system-defaults.nix
      ];
    };

    profileHomeModules = {
      "work" = [
        ./profiles/work/home-manager.nix
      ];
    };

    # Base configuration shared across all hosts
    mkBaseConfiguration = { username }: { pkgs, ... }: {
      # Import shared system packages and fonts
      imports = [
        ./common/nix-packages.nix
      ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # based on https://github.com/nix-darwin/nix-darwin/issues/1457
      system.primaryUser = username;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      nixpkgs.config.allowUnfree = true;

      # Override fish package to disable tests (they fail on darwin)
      nixpkgs.overlays = [
        (final: prev: {
          fish = prev.fish.overrideAttrs (oldAttrs: {
            doCheck = false;
          });
        })
      ];

      # ref: https://github.com/LnL7/nix-darwin/issues/1237#issuecomment-2562242340
      # to set fish shells as default
      users.knownUsers = [ username ];
      users.users.${username} = {
        name = username;
        home = "/Users/${username}";
        shell = pkgs.fish;
        uid = 501;
      };
    };

    # Helper function to create darwin configurations
    mkDarwinConfig = import ./lib/mkDarwinConfig.nix {
      inherit nix-darwin home-manager inputs mkBaseConfiguration profileSystemModules profileHomeModules;
    };
  in
  flake-parts.lib.mkFlake { inherit inputs; } {
    # Supported systems
    systems = [ "aarch64-darwin" ];

    # Flake-level outputs (darwin configurations)
    flake = {
      darwinConfigurations = nixpkgs.lib.mapAttrs (_: mkDarwinConfig) hostConfigs;
    };

    # Per-system outputs
    perSystem = { pkgs, ... }: {
      # Import development shells from shells folder
      devShells = import ./shells { inherit pkgs; };
    };
  };
}
