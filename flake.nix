{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

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
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, home-manager }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget

      environment.systemPackages =
        [ pkgs.bat
          pkgs.bun
          pkgs.deno
          pkgs.fzf
          pkgs.fishPlugins.forgit
          pkgs.fishPlugins.tide
          pkgs.fishPlugins.sponge
          pkgs.fishPlugins.sdkman-for-fish
          pkgs.fishPlugins.colored-man-pages
          pkgs.fishPlugins.z
          pkgs.fishPlugins.done
          pkgs.go
          pkgs.git
          pkgs.lazygit
          pkgs.lsd
          pkgs.pnpm
          pkgs.vim
          pkgs.wget
          pkgs.appcleaner
          pkgs.discord
          pkgs.google-chrome
          pkgs.iina
          pkgs.postman
          pkgs.ripgrep
          pkgs.slack
          pkgs.vscode
          pkgs.wezterm
          pkgs.wifi-password
          pkgs.zoom-us
        ];

      fonts.packages = with pkgs; [
        nerd-fonts.im-writing
        nerd-fonts.hack
        nerd-fonts.blex-mono
        nerd-fonts.jetbrains-mono
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

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      nixpkgs.config.allowUnfree = true;

      system.activationScripts.postUserActivation.text = ''
        # Following line should allow us to avoid a logout/login cycle
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';

      # ref: https://github.com/LnL7/nix-darwin/issues/1237#issuecomment-2562242340
      # to set fish shells as default
      users.knownUsers = ["milhamh95"];
      users.users.milhamh95 = {
        name = "milhamh95";
        home = "/Users/milhamh95";
        shell = pkgs.fish;
        uid = 501;
      };

      networking.computerName = "milhamh95 Macbook Pro";

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."mbp" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        ./system-defaults.nix

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            user = "milhamh95";

            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
            };

            autoMigrate = true;
          };
        }

        {
          homebrew = {
            enable = true;

            brews = [
              "mas"
            ];

            casks = [
              "alt-tab"
              "appcleaner"
              "betterdisplay"
              "bettermouse"
              "brave-browser"
              "dbngin"
              "elgato-stream-deck"
              "floorp"
              "github"
              "ghostty"
              "heptabase"
              "homerow"
              "hyperkey"
              "jordanbaird-ice"
              "leader-key"
              "librewolf"
              "logitune"
              "macupdater"
              "mediamate"
              "microsoft-edge"
              "orbstack"
              "postman@canary"
              "pritunl"
              "raycast"
              "rectangle-pro"
              "setapp"
              "whichspace"
              "zen-browser"
            ];

            masApps = {
              "Amphetamine" = 937984704;
              "DaisyDisk" = 411643860;
              "Fantastical - Calendar" = 975937182;
              "LilyView" = 529490330;
              "PDF Expert – Edit, Sign PDFs" = 1055273043;
              "rcmd • App Switcher" = 1596283165;
              "Spark Classic – Email App" = 1176895641;
            };

            onActivation.cleanup = "zap";
            onActivation.autoUpdate = true;
            onActivation.upgrade = true;

          };
        }

        home-manager.darwinModules.home-manager
        {
          # `home-manager` config
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.milhamh95 = import ./home-manager.nix;
          home-manager.backupFileExtension = "backup";
        }
      ];
    };
  };
}
