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

    # process-compose-flake for running services
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";

    # services-flake for pre-configured service modules
    services-flake.url = "github:juspay/services-flake";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, nix-homebrew,
                     homebrew-core, homebrew-cask, homebrew-bundle,
                     home-manager, flake-parts, process-compose-flake,
                     services-flake, ... }:
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

    # Import process-compose flake module
    imports = [
      process-compose-flake.flakeModule
    ];

    # Flake-level outputs (darwin configurations)
    flake = {
      darwinConfigurations = {
        "mac-desktop" = mkDarwinConfig "mac-desktop";
        "mbp" = mkDarwinConfig "mbp";
      };
    };

    # Per-system outputs
    perSystem = { config, pkgs, system, lib, ... }: {
      # PostgreSQL service
      process-compose."postgres" = {
        imports = [
          inputs.services-flake.processComposeModules.default
        ];

        services.postgres."pg1" = {
          enable = true;
          package = pkgs.postgresql_17;
          port = 5433;
          listen_addresses = "127.0.0.1";
          initialDatabases = [
            { name = "milhamh95"; }
          ];
          settings = {
            unix_socket_directories = "/tmp";
          };
        };
      };

      # Redis service
      process-compose."redis" = {
        imports = [
          inputs.services-flake.processComposeModules.default
        ];

        services.redis."rd1" = {
          enable = true;
          port = 6380;
          bind = "127.0.0.1";
        };
      };

      # Development shells
      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [ postgresql_17 redis ];
          shellHook = ''
            echo "Development shell - PostgreSQL and Redis tools available"
            echo "Commands: nix run .#postgres | nix run .#redis"
          '';
        };

        postgres = pkgs.mkShell {
          packages = with pkgs; [ postgresql_17 ];
          shellHook = ''
            export PGPORT=5433
            export PGHOST=localhost
            export dataDir="$HOME/Documents/postgres_data"

            pg_create_db() {
              if [ -z "$1" ]; then
                echo "Usage: pg_create_db <database_name>"
                return 1
              fi
              createdb -h localhost -p $PGPORT "$1"
              echo "Database $1 created"
            }

            pg_status() {
              if pg_isready -h localhost -p $PGPORT > /dev/null 2>&1; then
                echo "PostgreSQL is running on port $PGPORT"
                psql -h localhost -p $PGPORT -l
              else
                echo "PostgreSQL is not running"
              fi
            }

            pg_help() {
              echo "PostgreSQL Development Shell Commands:"
              echo ""
              echo "  pg_status       - Check PostgreSQL status and list databases"
              echo "  pg_create_db    - Create a new database"
              echo "  psql            - Connect to PostgreSQL"
              echo ""
              echo "Start server: nix run .#postgres"
            }

            echo "PostgreSQL Dev Shell (port $PGPORT)"
            echo "Run 'pg_help' for available commands"
            echo "Start server: nix run .#postgres"
            psql --version
          '';
        };

        redis = pkgs.mkShell {
          packages = with pkgs; [ redis ];
          shellHook = ''
            export REDIS_PORT=6380
            export REDIS_DATA="$HOME/Documents/redis_data"

            redis_status() {
              if redis-cli -p $REDIS_PORT ping 2>/dev/null | grep -q PONG; then
                echo "Redis is running on port $REDIS_PORT"
              else
                echo "Redis is not running"
              fi
            }

            redis_help() {
              echo "Redis Development Shell Commands:"
              echo ""
              echo "  redis_status    - Check if Redis is running"
              echo "  redis_cli       - Open Redis CLI (alias for redis-cli -p $REDIS_PORT)"
              echo ""
              echo "Start server: nix run .#redis"
            }

            alias redis_cli="redis-cli -p $REDIS_PORT"

            echo "Redis Dev Shell (port $REDIS_PORT)"
            echo "Run 'redis_help' for available commands"
            echo "Start server: nix run .#redis"
            redis-server --version
          '';
        };
      };
    };
  };
}
