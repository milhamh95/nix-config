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
            echo "Use: nix develop .#postgres | nix develop .#redis"
          '';
        };

        postgres = pkgs.mkShell {
          packages = with pkgs; [ postgresql_17 ];
          shellHook = ''
            export PGPORT=5433
            export PGHOST=localhost
            export PGDATA="$HOME/Documents/postgres_data"

            # Initialize database if needed
            if [ ! -d "$PGDATA" ]; then
              echo "Initializing PostgreSQL data directory..."
              mkdir -p "$PGDATA"
              chmod 700 "$PGDATA"
              initdb -D "$PGDATA"
              echo "host all all 127.0.0.1/32 trust" >> "$PGDATA/pg_hba.conf"
              echo "listen_addresses='127.0.0.1'" >> "$PGDATA/postgresql.conf"
              echo "port=$PGPORT" >> "$PGDATA/postgresql.conf"
              echo "unix_socket_directories='/tmp'" >> "$PGDATA/postgresql.conf"
            fi

            pg_start() {
              if pg_ctl -D "$PGDATA" status > /dev/null 2>&1; then
                echo "PostgreSQL is already running"
                return 0
              fi
              echo "Starting PostgreSQL on port $PGPORT..."
              pg_ctl -D "$PGDATA" -l "$PGDATA/logfile" -o "-p $PGPORT -k /tmp" start
              if [ $? -eq 0 ]; then
                echo "PostgreSQL started successfully"
              else
                echo "Failed to start PostgreSQL. Check $PGDATA/logfile"
              fi
            }

            pg_stop() {
              if pg_ctl -D "$PGDATA" status > /dev/null 2>&1; then
                echo "Stopping PostgreSQL..."
                pg_ctl -D "$PGDATA" stop
                echo "PostgreSQL stopped"
              else
                echo "PostgreSQL is not running"
              fi
            }

            pg_status() {
              if pg_isready -h localhost -p $PGPORT > /dev/null 2>&1; then
                echo "PostgreSQL is running on port $PGPORT"
                psql -h localhost -p $PGPORT -l
              else
                echo "PostgreSQL is not running"
              fi
            }

            pg_create_db() {
              if [ -z "$1" ]; then
                echo "Usage: pg_create_db <database_name>"
                return 1
              fi
              createdb -h localhost -p $PGPORT "$1"
              echo "Database '$1' created"
            }

            pg_help() {
              echo ""
              echo "PostgreSQL Commands:"
              echo "  pg_start      - Start PostgreSQL server"
              echo "  pg_stop       - Stop PostgreSQL server"
              echo "  pg_status     - Check status and list databases"
              echo "  pg_create_db  - Create a new database"
              echo "  psql          - Connect to PostgreSQL"
              echo "  pg_help       - Show this help"
              echo ""
            }

            echo ""
            echo "=== PostgreSQL Dev Shell ==="
            echo "Port: $PGPORT | Data: $PGDATA"
            psql --version
            pg_help
          '';
        };

        redis = pkgs.mkShell {
          packages = with pkgs; [ redis ];
          shellHook = ''
            export REDIS_PORT=6380
            export REDIS_DATA="$HOME/Documents/redis_data"
            export REDIS_CONF="$REDIS_DATA/redis.conf"
            export REDIS_PID="$REDIS_DATA/redis.pid"

            # Initialize redis data directory if needed
            if [ ! -d "$REDIS_DATA" ]; then
              echo "Initializing Redis data directory..."
              mkdir -p "$REDIS_DATA"
            fi

            # Create config if needed
            if [ ! -f "$REDIS_CONF" ]; then
              cat > "$REDIS_CONF" << EOF
            port $REDIS_PORT
            bind 127.0.0.1
            dir $REDIS_DATA
            dbfilename dump.rdb
            pidfile $REDIS_PID
            daemonize yes
            logfile $REDIS_DATA/redis.log
            EOF
            fi

            redis_start() {
              if [ -f "$REDIS_PID" ] && kill -0 $(cat "$REDIS_PID") 2>/dev/null; then
                echo "Redis is already running"
                return 0
              fi
              echo "Starting Redis on port $REDIS_PORT..."
              redis-server "$REDIS_CONF"
              sleep 1
              if redis-cli -p $REDIS_PORT ping 2>/dev/null | grep -q PONG; then
                echo "Redis started successfully"
              else
                echo "Failed to start Redis. Check $REDIS_DATA/redis.log"
              fi
            }

            redis_stop() {
              if [ -f "$REDIS_PID" ] && kill -0 $(cat "$REDIS_PID") 2>/dev/null; then
                echo "Stopping Redis..."
                redis-cli -p $REDIS_PORT shutdown 2>/dev/null
                echo "Redis stopped"
              else
                echo "Redis is not running"
              fi
            }

            redis_status() {
              if redis-cli -p $REDIS_PORT ping 2>/dev/null | grep -q PONG; then
                echo "Redis is running on port $REDIS_PORT"
                redis-cli -p $REDIS_PORT info server | grep -E "^(redis_version|uptime)"
              else
                echo "Redis is not running"
              fi
            }

            redis_help() {
              echo ""
              echo "Redis Commands:"
              echo "  redis_start   - Start Redis server"
              echo "  redis_stop    - Stop Redis server"
              echo "  redis_status  - Check Redis status"
              echo "  redis-cli -p $REDIS_PORT  - Connect to Redis"
              echo "  redis_help    - Show this help"
              echo ""
            }

            echo ""
            echo "=== Redis Dev Shell ==="
            echo "Port: $REDIS_PORT | Data: $REDIS_DATA"
            redis-server --version
            redis_help
          '';
        };
      };
    };
  };
}
