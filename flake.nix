{
  description = "Nix Darwin Config for Mac";

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
        [
          pkgs.atuin
          pkgs.bat
          pkgs.bun
          pkgs.deno
          pkgs.fastfetch
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
          pkgs.nodejs_22
          pkgs.pnpm
          pkgs.ripgrep
          pkgs.uv
          pkgs.vim
          pkgs.wget
          pkgs.wifi-password
          pkgs.yarn-berry_4
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

      system.primaryUser = "milhamh95";

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      nixpkgs.config.allowUnfree = true;

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

    mkDarwinConfig = hostname: nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        ./system-defaults.nix

        # Add hostname printing script
        {
          system.activationScripts.displayHostname = {
            text = ''
              echo "🖥️  Building configuration for hostname: ${hostname}"
            '';
            deps = [];
          };
        }

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

        {
          homebrew = {
            enable = true;
            brews = [
              "helix"
              "mas"
            ];
            casks = [
              "alt-tab"
              "appcleaner"
              "batfi"
              "betterdisplay"
              "bettermouse"
              "brave-browser"
              "discord"
              "elgato-stream-deck"
              "flashspace"
              "floorp"
              "github"
              "ghostty"
              "google-chrome"
              "hammerspoon"
              "heptabase"
              "homerow"
              "iina"
              "jordanbaird-ice"
              "karabiner-elements"
              "logitune"
              "macupdater"
              "microsoft-edge"
              "orbstack"
              "postman"
              "postman@canary"
              "pritunl"
              "raycast"
              "rectangle-pro"
              "setapp"
              "slack"
              "visual-studio-code"
              "wezterm"
              "windsurf"
              "zen-browser"
              "zoom"
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
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.milhamh95 = import ./home-manager.nix { inherit hostname; };
          home-manager.backupFileExtension = "backup";
        }
      ];
    };
  in
  {
    darwinConfigurations = {
      "mac-desktop" = mkDarwinConfig "mac-desktop";
      "mbp" = mkDarwinConfig "mbp";
    };
  };
}
