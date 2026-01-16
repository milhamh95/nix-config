{
  description = "Nix Darwin Config for Mac";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # flake-parts for modular flake structure
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, nix-homebrew,
                     homebrew-core, homebrew-cask, homebrew-bundle,
                     home-manager, flake-parts, ... }:
  let
    # Host configurations - define username per machine
    hostConfigs = {
      "mac-desktop" = {
        hostname = "mac-desktop";
        username = "milhamh95";
      };
      "mbp" = {
        hostname = "mbp";
        username = "milhamh95";  # Change this to your MacBook Pro username
      };
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
    mkDarwinConfig = hostConfig:
      let
        hostname = hostConfig.hostname;
        username = hostConfig.username;
      in
      nix-darwin.lib.darwinSystem {
        modules = [
          # Base system configuration
          (mkBaseConfiguration { inherit username; })

          # Common modules (shared across all hosts)
          ./common/system-defaults.nix
          ./common/homebrew.nix

          # Host-specific modules
          ./hosts/${hostname}/default.nix
          ./hosts/${hostname}/nix-packages.nix
          ./hosts/${hostname}/system-defaults.nix
          ./hosts/${hostname}/homebrew.nix

          # Debug trace (optional)
          ({ lib, ... }: {
            nixpkgs.config = lib.mkOrder 1500 (builtins.trace "Building configuration for hostname: ${hostname}, username: ${username}" {});
          })

          # Homebrew setup
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = username;
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };
              autoMigrate = true;
            };
          }

          # Home-manager configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = { config, pkgs, lib, ... }: {
              imports = [
                ./common/home-manager.nix
                ./hosts/${hostname}/home-manager.nix
              ];
            };
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
  in
  flake-parts.lib.mkFlake { inherit inputs; } {
    # Supported systems
    systems = [ "aarch64-darwin" "x86_64-darwin" ];

    # Flake-level outputs (darwin configurations)
    flake = {
      darwinConfigurations = {
        "mac-desktop" = mkDarwinConfig hostConfigs."mac-desktop";
        "mbp" = mkDarwinConfig hostConfigs."mbp";
      };
    };

    # Per-system outputs
    perSystem = { pkgs, ... }: {
      # Import development shells from shells folder
      devShells = import ./shells { inherit pkgs; };
    };
  };
}
