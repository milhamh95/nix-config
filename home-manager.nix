{ config, pkgs, lib, ... }: {
  home.stateVersion = "25.05";

  home.activation = {
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
    configureSdkman = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e "$HOME/sdkman_configured" ]; then
        echo "Configuring SDKMAN... ⚙️"
        export PATH="/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
        /usr/bin/curl -s "https://get.sdkman.io" | /bin/bash
        $DRY_RUN_CMD touch "$HOME/sdkman_configured"
        echo "SDKMAN configured ✅"
      fi
    '';
    configureHammerflow = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -e "$HOME/.hammerspon/Spoons/Hammerflow.spoon" ]; then
        echo "Configuring Hammerflow... ⚙️"
        export PATH="/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
        $DRY_RUN_CMD mkdir -p $HOME/.hammerspoon
        $DRY_RUN_CMD git clone https://github.com/saml-dev/Hammerflow.spoon.git $HOME/.hammerspoon/Spoons/Hammerflow.spoon
        $DRY_RUN_CMD cp -f ${./hammerflow/home.toml} $HOME/.hammerspoon/home.toml
        $DRY_RUN_CMD cp -f ${./hammerflow/init.lua} $HOME/.hammerspoon/init.lua
        echo "Hammerflow configured ✅"
      fi
    '';
  };

  home.file.".config/ghostty/config".text = ''
    font-size = 16
    theme = catppuccin-mocha
    cursor-style = bar
    confirm-close-surface = false
    shell-integration = "fish"
    bold-is-bright = true
    cursor-style-blink = true
    macos-titlebar-style = "transparent"
    macos-window-shadow = false
    custom-shader-animation = true
    window-padding-x = 8
    window-padding-y = 5
    window-padding-color = "background"
    background-opacity = 1
    font-family = "BlexMono Nerd Font Mono"
    window-inherit-working-directory = false
  '';

  home.file.".config/karabiner/karabiner.json".text = builtins.toJSON {
    profiles = [
      {
        complex_modifications = {
          rules = [
            {
              description = "Mac OSX: double-tap right shift key → caps lock toggle";
              manipulators = [
                {
                  conditions = [
                    {
                      name = "right_shift pressed";
                      type = "variable_if";
                      value = 1;
                    }
                  ];
                  from = {
                    key_code = "right_shift";
                    modifiers.optional = ["any"];
                  };
                  to = [{ key_code = "caps_lock"; }];
                  type = "basic";
                }
                {
                  from = {
                    key_code = "right_shift";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {
                      set_variable = {
                        name = "right_shift pressed";
                        value = 1;
                      };
                    }
                    { key_code = "right_shift"; }
                  ];
                  to_delayed_action = {
                    to_if_canceled = [
                      {
                        set_variable = {
                          name = "right_shift pressed";
                          value = 0;
                        };
                      }
                    ];
                    to_if_invoked = [
                      {
                        set_variable = {
                          name = "right_shift pressed";
                          value = 0;
                        };
                      }
                    ];
                  };
                  type = "basic";
                }
              ];
            }
            {
              description = "Hyper Key: Caps Lock → left control + left shift + right command (⌃⇧⌘). Quick Caps Lock → Escape";
              manipulators = [
                {
                  from = {
                    key_code = "caps_lock";
                    modifiers.optional = ["any"];
                  };
                  to = [
                    {
                      set_variable = {
                        name = "hyper_caps_lock";
                        value = 1;
                      };
                    }
                    {
                      key_code = "left_control";
                      modifiers = ["left_shift" "right_command"];
                    }
                  ];
                  to_after_key_up = [
                    {
                      set_variable = {
                        name = "hyper_caps_lock";
                        value = 0;
                      };
                    }
                  ];
                  to_if_alone = [{ key_code = "escape"; }];
                  type = "basic";
                }
              ];
            }
          ];
        };
        name = "Default profile";
        selected = true;
        simple_modifications = [
          {
            from = { key_code = "right_command"; };
            to = [{ key_code = "f18"; }];
          }
        ];
        virtual_hid_keyboard.keyboard_type_v2 = "ansi";
      }
    ];
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'

      local config = wezterm.config_builder()
      local act = wezterm.action

      config.color_scheme = 'Dracula'
      config.font = wezterm.font('BlexMono Nerd Font Mono')
      config.font_size = 15.0
      config.line_height = 1.2
      config.default_cursor_style = 'BlinkingBar'
      config.window_close_confirmation = 'NeverPrompt'
      config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
      config.hide_mouse_cursor_when_typing = false
      config.default_cwd = '~'
      config.max_fps = 120

      config.keys = {
          {
              key = 'LeftArrow',
              mods = 'OPT',
              action = act.SendKey {
                  key = 'b',
                  mods = 'ALT'
              }
          },
          {
              key = 'RightArrow',
              mods = 'OPT',
              action = act.SendKey {
                  key = 'f',
                  mods = 'ALT'
              }
          },
          {
              key = 'LeftArrow',
              mods = 'SUPER',
              action = act.SendKey {
                  key = 'a',
                  mods = 'CTRL'
              }
          },
          {
              key = 'RightArrow',
              mods = 'SUPER',
              action = act.SendKey {
                  key = 'e',
                  mods = 'CTRL'
              }
          },
          {
              key = 'LeftArrow',
              mods = 'CMD|OPT',
              action = act.ActivateTabRelative(-1)
          },
          {
              key = 'RightArrow',
              mods = "CMD|OPT",
              action = act.ActivateTabRelative(1)
          },
          {
              key = 'Backspace',
              mods = 'SUPER',
              action = act.SendKey {
                  key = 'u',
                  mods = 'CTRL'
              }
          },
          {
              key = 'LeftArrow',
              mods = 'CMD|SHIFT',
              action = act.MoveTabRelative(-1)
          },
          {
              key = 'RightArrow',
              mods = 'CMD|SHIFT',
              action = act.MoveTabRelative(1)
          },
          {
              key = 't',
              mods = 'CMD|SHIFT',
              action = act.ShowTabNavigator
          },
          {
              key = 'Enter',
              mods = 'ALT',
              action = wezterm.action.DisableDefaultAssignment
          },
          {
              key = 't',
              mods = 'CMD',
              action = act({ SpawnCommandInNewTab = { cwd = wezterm.home_dir } })
          },
      }

      return config
    '';
  };

  xdg.enable = true;

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
