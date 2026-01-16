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
    # Existing configuration function
    configuration = { pkgs, ... }: {
      # Import system packages and fonts configuration
      imports = [
        ./nix-packages.nix
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
      system.primaryUser = "milhamh95";

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
      users.knownUsers = ["milhamh95"];
      users.users.milhamh95 = {
        name = "milhamh95";
        home = "/Users/milhamh95";
        shell = pkgs.fish;
        uid = 501;
      };
    };

    # Existing mkDarwinConfig helper
    mkDarwinConfig = hostname: nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        ./system-defaults.nix

        ({ lib, ... }: {
          nixpkgs.config = lib.mkOrder 1500 (builtins.trace "Building configuration for hostname: ${hostname}" {});
        })

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            user = "milhamh95";
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
            };
            autoMigrate = true;
          };
        }

        # Import Homebrew package configuration
        ./homebrew.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.milhamh95 = import ./home-manager.nix { inherit hostname; };
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
        "mac-desktop" = mkDarwinConfig "mac-desktop";
        "mbp" = mkDarwinConfig "mbp";
      };
    };

    # Per-system outputs
    perSystem = { pkgs, ... }: {
      # Import development shells from shells folder
      devShells = import ./shells { inherit pkgs; };
    };
  };
}
