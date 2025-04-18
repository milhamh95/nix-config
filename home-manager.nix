{ hostname }: { config, pkgs, lib, ... }: {
  home.stateVersion = "25.05";

  home.activation = {
    configureGit = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e "$HOME/git_configured" ]; then
        echo "Configuring Git... ⚙️"

        echo "Copying Git config files..."
        $DRY_RUN_CMD cp ${./git/.gitconfig} "$HOME/.gitconfig"
        $DRY_RUN_CMD cp ${./git/.gitconfig-personal} "$HOME/.gitconfig-personal"
        $DRY_RUN_CMD cp ${./git/.gitignore} "$HOME/.gitignore"

        $DRY_RUN_CMD touch "$HOME/git_configured"
        echo "Git configured ✅"
      fi
    '';
    configureSsh = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e "$HOME/ssh_configured" ]; then
        echo "Configuring SSH... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.ssh"
        $DRY_RUN_CMD cp ${./ssh/id_github_personal.pub} "$HOME/.ssh/id_github_personal.pub"
        $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_github_personal.pub"

        echo "Setting up SSH config..."
        if [ -f "$HOME/.ssh/config" ]; then
          echo "Appending to existing SSH config..."
          $DRY_RUN_CMD cat ${./ssh/config} >> "$HOME/.ssh/config"
        else
          echo "Creating new SSH config..."
          $DRY_RUN_CMD cp ${./ssh/config} "$HOME/.ssh/config"
        fi
        $DRY_RUN_CMD chmod 600 "$HOME/.ssh/config"

        $DRY_RUN_CMD touch "$HOME/ssh_configured"
        echo "SSH configured ✅"
      fi
    '';
    configureTide = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e "$HOME/.config/fish/tide_configured" ]; then
        echo "Configuring Tide... ⚙️"
        export TERM=xterm-256color
        $DRY_RUN_CMD ${pkgs.fish}/bin/fish -c 'tide configure --auto --style=Rainbow --prompt_colors="True color" --show_time=No --rainbow_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style="Two lines, character and frame" --prompt_connection=Disconnected --powerline_right_prompt_frame=Yes --prompt_connection_andor_frame_color=Lightest --prompt_spacing=Sparse --icons="Many icons" --transient=No'
        $DRY_RUN_CMD touch "$HOME/.config/fish/tide_configured"
        echo "Finish Configuring Tide... ✅"
      fi
    '';
    configureCleanShot = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/Documents/cleanshot" ]; then
        echo "Creating CleanShot directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/Documents/cleanshot"
        echo "CleanShot directory created at $HOME/Documents/cleanshot ✅"
      fi
    '';
    configureWorkFolder = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/work" ]; then
        echo "Creating Work directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/work"
        echo "Work directory created at $HOME/work ✅"
      fi
    '';
    configurePersonalFolder = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/personal" ]; then
        echo "Creating Personal directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/personal"
        echo "Personal directory created at $HOME/personal ✅"
      fi
    '';
    configureSdkman = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e "$HOME/sdkman_configured" ]; then
        echo "Configuring SDKMAN... ⚙️"
        export PATH="/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
        /usr/bin/curl -s "https://get.sdkman.io" | /bin/bash
        $DRY_RUN_CMD touch "$HOME/sdkman_configured"
        echo "SDKMAN configured ✅"
      fi
    '';
    configureFastfetch = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ ! -d "$HOME/.config/fastfetch" ]; then
        echo "Configuring Fastfetch... ⚙️"
        $DRY_RUN_CMD ${pkgs.fastfetch}/bin/fastfetch  --gen-config
        if [ -d "$HOME/.config/fastfetch" ]; then
          echo "Fastfetch configured ✅"
        else
          echo "⚠️ Something is wrong when configuring Fastfetch"
        fi
      fi
    '';
    configureGhostty = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ ! -d "$HOME/.config/ghostty" ]; then
        echo "Creating Ghostty config directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.config/ghostty"
        echo "Copying initial Ghostty config... ⚙️"
        $DRY_RUN_CMD cp ${./ghostty/config} "$HOME/.config/ghostty/config"
        echo "Ghostty configured ✅"
      fi
    '';
    configureFlashspace = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ ! -d "$HOME/.config/flashspace" ]; then
        echo "Creating FlashSpace config directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.config/flashspace"
        echo "Copying FlashSpace config files..."
        if [ "${hostname}" = "mac-desktop" ]; then
          $DRY_RUN_CMD cp ${./flashspace/desktop/settings.json} "$HOME/.config/flashspace/settings.json"
          $DRY_RUN_CMD cp ${./flashspace/desktop/profiles.json} "$HOME/.config/flashspace/profiles.json"
        else
          $DRY_RUN_CMD cp ${./flashspace/mbp/settings.json} "$HOME/.config/flashspace/settings.json"
          $DRY_RUN_CMD cp ${./flashspace/mbp/profiles.json} "$HOME/.config/flashspace/profiles.json"
        fi
        echo "FlashSpace configured ✅"
      fi
    '';
    configureKarabiner = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ ! -d "$HOME/.config/karabiner" ]; then
        echo "Creating Karabiner config directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.config/karabiner"
        echo "Copying Karabiner config file..."
        $DRY_RUN_CMD cp ${./karabiner/karabiner.json} "$HOME/.config/karabiner/karabiner.json"
        echo "Karabiner configured ✅"
      fi
    '';
    configureWezTerm = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ ! -f "$HOME/.wezterm.lua" ]; then
        echo "Creating WezTerm config... ⚙️"
        $DRY_RUN_CMD cp ${./wezterm/wezterm.lua} "$HOME/.wezterm.lua"
        echo "WezTerm config created ✅"
      fi
    '';
    configureHammerflow = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ ! -d "$HOME/.hammerspoon" ]; then
        echo "Creating Hammerspoon directories... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.hammerspoon"

        echo "Cloning Hammerflow repository... ⚙️"
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/saml-dev/Hammerflow.spoon.git "$HOME/.hammerspoon/Spoons/Hammerflow.spoon"

        echo "Copying Hammerflow config files..."
        $DRY_RUN_CMD cp ${./hammerflow/home.toml} "$HOME/.hammerspoon/home.toml"
        $DRY_RUN_CMD cp ${./hammerflow/init.lua} "$HOME/.hammerspoon/init.lua"
        echo "Hammerflow configured ✅"
      fi
    '';
  };

  home.file = {
    ".config/ghostty/config" = {
      source = ./ghostty/config;
      onChange = ''
        echo "Ghostty config changed"
      '';
    };
    ".config/flashspace/profiles.json" = {
      source = if hostname == "mac-desktop"
               then ./flashspace/desktop/profiles.json
               else ./flashspace/mbp/profiles.json;
      onChange = ''
        echo "Flashspace profiles changed"
      '';
    };
    ".config/flashspace/settings.json" = {
      source = if hostname == "mac-desktop"
               then ./flashspace/desktop/settings.json
               else ./flashspace/mbp/settings.json;
      onChange = ''
        echo "Flashspace settings changed"
      '';
    };
    ".config/karabiner/karabiner.json" = {
      source = ./karabiner/karabiner.json;
      onChange = ''
        echo "Karabiner config changed"
      '';
    };
    ".wezterm.lua" = {
      source = ./wezterm/wezterm.lua;
      onChange = ''
        echo "WezTerm config changed"
      '';
    };
    ".hammerspoon/home.toml" = {
      source = ./hammerflow/home.toml;
      onChange = ''
        echo "Hammerspoon home config changed"
      '';
    };
    ".hammerspoon/init.lua" = {
      source = ./hammerflow/init.lua;
      onChange = ''
        echo "Hammerspoon init config changed"
      '';
    };
  };

  xdg.enable = true;

  programs.fastfetch = {
    enable = true;
    settings = {
      display = {
        separator = " ";
      };
      modules = [
        "break"
        {
          type = "custom";
          format = "┌───────────────────────────────Hardware──────────────────────────────────┐";
          outputColor = "cyan";
        }
        {
          type = "host";
          key = " System ";
          keyColor = "red";
        }
        {
          type = "cpu";
          key = "│ ├ CPU";
          keyColor = "red";
        }
        {
          type = "gpu";
          key = "│ ├󰒆 GPU";
          keyColor = "red";
        }
        {
          type = "memory";
          key = "│ ├󰍛 RAM";
          keyColor = "red";
        }
        {
          type = "disk";
          key = "│ ├ Disk";
          folders = "/";
          format = "{size-used} / {size-total} ({size-percentage})";
          keyColor = "red";
        }
        {
          type = "display";
          key = "└ └ Monitor";
          keyColor = "red";
          format = "({name}) {width}x{height} @ {refresh-rate} Hz - ({inch} inches, {ppi} ppi)";
        }
        {
          type = "custom";
          format = "└─────────────────────────────────────────────────────────────────────────┘";
          outputColor = "cyan";
        }
        {
          type = "custom";
          format = "┌───────────────────────────────Software──────────────────────────────────┐";
          outputColor = "cyan";
        }
        {
          type = "os";
          key = " OS ";
          keyColor = "green";
        }
        {
          type = "kernel";
          key = "│ ├ ";
          keyColor = "green";
        }
        {
          type = "packages";
          key = "│ ├󰏖 ";
          keyColor = "green";
        }
        {
          type = "localip";
          key = "└ └IP";
          keyColor = "green";
        }
        {
          type = "terminal";
          key = " Terminal ";
          keyColor = "blue";
        }
        {
          type = "shell";
          key = "│ ├ ";
          keyColor = "blue";
        }
        {
          type = "terminalfont";
          key = "└ └ ";
          keyColor = "blue";
        }
        {
          type = "custom";
          format = "└─────────────────────────────────────────────────────────────────────────┘";
          outputColor = "cyan";
        }
      ];
    };
  };

  programs.fish = {
    enable = true;
    functions = {
      current_branch = "git branch --show-current";
      mkcd = ''
        function mkcd --description "Create and change directory"
          if test (count $argv) -ne 1
              echo "Usage: mkcd <directory>"
              return 1
          end

          mkdir -p $argv[1] && cd $argv[1]
        end
      '';
    };
    plugins = [
      {
        name = "fisher";
          src = pkgs.fetchFromGitHub {
            owner = "jorgebucaran";
            repo = "fisher";
            rev = "4.4.5";
            sha256 = "sha256-VC8LMjwIvF6oG8ZVtFQvo2mGdyAzQyluAGBoK8N2/QM=";  # Replace with the correct hash
          };
      }
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
    ];

    shellAbbrs = {
      vc = "open $1 -a \"Visual Studio Code\"";
      ws = "open $1 -a \"Windsurf\"";
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gs = "git status";
      gpo = "git push origin";
      gpof = "git push --force-with-lease origin";
      gpoc = "git push origin (current_branch)";
      gpofc = "git push --force-with-lease origin (current_branch)";
      gplro = "git pull --rebase origin (current_branch)";
      gco = "git checkout";
      gcob = "git checkout -b";
      gcmv = "git commit -v";
      gcmm = "git commit -m";
      gss = "git status -s";
      gbd = "git branch -D";
      gbod = "git push origin -d";
      gl = "git log --color --pretty=format:'%Cred%h%Creset - %s %Cgreen(%ad) %C(bold blue)<%an - %C(yellow)%ae>% %Creset' --abbrev-commit --date=format:'%Y-%m-%d %H:%M:%S'";
      gls = "git log --color --all --date-order --decorate --dirstat=lines,cumulative --stat | sed 's/\([0-9] file[s]\? changed\)/\1\n_______\n-------/g' | less -R";
      pch = "echo 123";
      ls = "lsd --group-dirs=first -1";
      lsaf = "lsd -AF --group-dirs=first -1";
      lsla = "lsd -la";
      prsl = "cd /Users/milhamh95/personal";
      work = "cd /Users/milhamh95/work";
    };
    shellInit = ''
      set -g fish_greeting
    '';
    interactiveShellInit = ''
      # install catppuccin
      if not test -e $__fish_config_dir/themes/Catppuccin\ Mocha.theme
        fisher install catppuccin/fish
        fish_config theme save "Catppuccin Mocha"
      end
    '';
  };
}
