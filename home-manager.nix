{ hostname }: { config, pkgs, lib, ... }: {
  home.stateVersion = "25.05";

  home.activation = {
    configureGit = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e "$HOME/git_configured" ]; then
        echo "Configuring Git... ⚙️"

        echo "Copying Git config files..."
        $DRY_RUN_CMD cp ${./app-config/git/.gitconfig} "$HOME/.gitconfig"
        $DRY_RUN_CMD cp ${./app-config/git/.gitconfig-personal} "$HOME/.gitconfig-personal"
        $DRY_RUN_CMD cp ${./app-config/git/.gitignore} "$HOME/.gitignore"

        $DRY_RUN_CMD touch "$HOME/git_configured"
        echo "Git configured ✅"
      fi
    '';
    configureSsh = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e "$HOME/ssh_configured" ]; then
        echo "Configuring SSH... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.ssh"
        $DRY_RUN_CMD cp ${./app-config/ssh/id_github_personal.pub} "$HOME/.ssh/id_github_personal.pub"
        $DRY_RUN_CMD chmod 644 "$HOME/.ssh/id_github_personal.pub"

        echo "Setting up SSH config..."
        if [ -f "$HOME/.ssh/config" ]; then
          echo "Appending to existing SSH config..."
          $DRY_RUN_CMD cat ${./app-config/ssh/config} >> "$HOME/.ssh/config"
        else
          echo "Creating new SSH config..."
          $DRY_RUN_CMD cp ${./app-config/ssh/config} "$HOME/.ssh/config"
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
        $DRY_RUN_CMD cp ${./app-config/ghostty/config} "$HOME/.config/ghostty/config"
        echo "Ghostty configured ✅"
      fi
    '';
    configureFlashspace = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ ! -d "$HOME/.config/flashspace" ]; then
        echo "Creating FlashSpace config directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.config/flashspace"
        echo "Copying FlashSpace config files..."
        $DRY_RUN_CMD cp ${./app-config/flashspace/settings.json} "$HOME/.config/flashspace/settings.json"
        $DRY_RUN_CMD cp ${./app-config/flashspace/profiles.json} "$HOME/.config/flashspace/profiles.json"
        echo "FlashSpace configured ✅"
      fi
    '';
    configureKarabiner = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ ! -d "$HOME/.config/karabiner" ]; then
        echo "Creating Karabiner config directory... ⚙️"
        $DRY_RUN_CMD mkdir -p "$HOME/.config/karabiner"
        echo "Copying Karabiner config file..."
        $DRY_RUN_CMD cp ${./app-config/karabiner/karabiner.json} "$HOME/.config/karabiner/karabiner.json"
        echo "Karabiner configured ✅"
      fi

      if [ -f "$HOME/.config/karabiner/karabiner.json.backup" ]; then
        echo "Removing existing Karabiner backup file..."
        $DRY_RUN_CMD rm -f "$HOME/.config/karabiner/karabiner.json.backup"
        echo "Karabiner backup file removed ✅"
      fi
    '';
    configureWezTerm = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ ! -f "$HOME/.wezterm.lua" ]; then
        echo "Creating WezTerm config... ⚙️"
        $DRY_RUN_CMD cp ${./app-config/wezterm/wezterm.lua} "$HOME/.wezterm.lua"
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
        $DRY_RUN_CMD cp ${./app-config/hammerflow/home.toml} "$HOME/.hammerspoon/home.toml"
        $DRY_RUN_CMD cp ${./app-config/hammerflow/init.lua} "$HOME/.hammerspoon/init.lua"
        echo "Hammerflow configured ✅"
      fi
    '';
  };

  home.file = {
    ".config/sftpgo/sftpgo.json" = {
      text = builtins.toJSON (let
        sftpgoTemplatesPath = "${pkgs.sftpgo}/share/sftpgo/templates";
        sftpgoStaticPath = "${pkgs.sftpgo}/share/sftpgo/static";
        sftpgoOpenApiPath = "${pkgs.sftpgo}/share/sftpgo/openapi";
      in {
        sftpd = {
          bindings = [{
            port = 2022;
            address = "";
            apply_proxy_config = true;
          }];
          max_auth_tries = 0;
          host_keys = [];
          host_certificates = [];
          host_key_algorithms = [];
          kex_algorithms = [];
          ciphers = [];
          macs = [];
          banner = "";
          trusted_user_ca_keys = [];
          login_banner_file = "";
          enabled_ssh_commands = [
            "md5sum" "sha1sum" "sha256sum" "sha384sum" "sha512sum"
            "cd" "pwd" "scp"
          ];
          keyboard_interactive_authentication = false;
          keyboard_interactive_auth_hook = "";
          password_authentication = true;
          folder_prefix = "";
        };
        ftpd = {
          bindings = [];
          banner = "";
          banner_file = "";
          active_transfers_port_non_20 = true;
          passive_port_range = {
            start = 0;
            end = 0;
          };
          disable_active_mode = false;
          enable_site = false;
          hash_support = 0;
          combine_support = 0;
          certificate_file = "";
          certificate_key_file = "";
          ca_certificates = [];
          ca_revocation_lists = [];
        };
        webdavd = {
          bindings = [];
          certificate_file = "";
          certificate_key_file = "";
          ca_certificates = [];
          ca_revocation_lists = [];
          cors = {
            enabled = false;
            allowed_origins = [];
            allowed_methods = [];
            allowed_headers = [];
            exposed_headers = [];
            allow_credentials = false;
            max_age = 0;
          };
          cache = {
            users = {
              expiration_time = 0;
              max_size = 50;
            };
            mime_types = {
              enabled = true;
              max_size = 1000;
            };
          };
        };
        data_provider = {
          driver = "sqlite";
          name = "sftpgo.db";
          host = "";
          port = 0;
          username = "";
          password = "";
          sslmode = 0;
          disable_sni = false;
          target_session_attrs = "";
          root_cert = "";
          client_cert = "";
          client_key = "";
          connection_string = "";
          sql_tables_prefix = "";
          track_quota = 2;
          delayed_quota_update = 0;
          pool_size = 0;
          users_base_dir = "";
          actions = {
            execute_on = [];
            execute_for = [];
            hook = "";
          };
          external_auth_hook = "";
          external_auth_scope = 0;
          credentials_path = "credentials";
          prefer_database_credentials = false;
          pre_login_hook = "";
          post_login_hook = "";
          post_login_scope = 0;
          check_password_hook = "";
          check_password_scope = 0;
          password_hashing = {
            bcrypt_options = {
              cost = 10;
            };
            argon2_options = {
              memory = 65536;
              iterations = 1;
              parallelism = 2;
            };
          };
          password_validation = {
            admins = {
              min_entropy = 0;
            };
            users = {
              min_entropy = 0;
            };
          };
          password_caching = true;
          update_mode = 0;
          skip_natural_keys_validation = false;
          create_default_admin = false;
          naming_rules = 0;
          is_shared = 0;
          backups_path = "backups";
        };
        httpd = {
          bindings = [{
            port = 8086;
            address = "";
            enable_web_admin = true;
            enable_web_client = true;
            enable_rest_api = true;
            enabled_login_methods = 0;
            enable_https = false;
            certificate_file = "";
            certificate_key_file = "";
            min_tls_version = 12;
            client_auth_type = 0;
            tls_cipher_suites = [];
            proxy_allowed = [];
            client_ip_proxy_header = "";
            client_ip_header_depth = 0;
            hide_login_url = 0;
            render_openapi = true;
            web_client_integrations = [];
            oidc = {
              client_id = "";
              client_secret = "";
              config_url = "";
              redirect_base_url = "";
              scopes = [ "openid" "profile" "email" ];
              username_field = "";
              role_field = "";
              implicit_roles = false;
              custom_fields = [];
              insecure_skip_signature_check = false;
              debug = false;
            };
            security = {
              enabled = false;
              allowed_hosts = [];
              allowed_hosts_are_regex = false;
              hosts_proxy_headers = [];
              https_redirect = false;
              https_host = "";
              https_proxy_headers = [];
              sts_seconds = 0;
              sts_include_subdomains = false;
              sts_preload = false;
              content_type_nosniff = false;
              content_security_policy = "";
              permissions_policy = "";
              cross_origin_opener_policy = "";
              expect_ct_header = "";
            };
            branding = {
              web_admin = {
                name = "";
                short_name = "";
                favicon_path = "";
                logo_path = "";
                login_image_path = "";
                disclaimer_name = "";
                disclaimer_path = "";
                default_css = [];
                extra_css = [];
              };
              web_client = {
                name = "";
                short_name = "";
                favicon_path = "";
                logo_path = "";
                login_image_path = "";
                disclaimer_name = "";
                disclaimer_path = "";
                default_css = [];
                extra_css = [];
              };
            };
          }];
          templates_path = sftpgoTemplatesPath;
          static_files_path = sftpgoStaticPath;
          openapi_path = sftpgoOpenApiPath;
          web_root = "";
          certificate_file = "";
          certificate_key_file = "";
          ca_certificates = [];
          ca_revocation_lists = [];
          signing_passphrase = "";
          signing_passphrase_file = "";
          token_validation = 0;
          max_upload_file_size = 0;
          cors = {
            enabled = false;
            allowed_origins = [];
            allowed_methods = [];
            allowed_headers = [];
            exposed_headers = [];
            allow_credentials = false;
            max_age = 0;
          };
          cache = {
            users = {
              expiration_time = 0;
              max_size = 50;
            };
            mime_types = {
              enabled = true;
              max_size = 1000;
            };
          };
        };
        telemetry = {
          bind_port = 0;
          bind_address = "127.0.0.1";
          enable_profiler = false;
          auth_user_file = "";
          certificate_file = "";
          certificate_key_file = "";
          min_tls_version = 12;
          tls_cipher_suites = [];
        };
        http = {
          timeout = 20;
          retry_wait_min = 2;
          retry_wait_max = 30;
          retry_max = 3;
          ca_certificates = [];
          certificates = [];
          skip_tls_verify = false;
          headers = [];
        };
        kms = {
          secrets = {
            url = "";
            master_key = "";
            master_key_path = "";
          };
        };
        mfa = {
          totp = [{
            name = "Default";
            issuer = "SFTPGo";
            algo = "sha1";
          }];
        };
        smtp = {
          host = "";
          port = 587;
          from = "";
          user = "";
          password = "";
          auth_type = 0;
          encryption = 0;
          domain = "";
          templates_path = "";
        };
        plugins = [];
        log = {
          file_path = "sftpgo.log";
          max_size = 10;
          max_backups = 5;
          max_age = 28;
          compress = false;
          level = "debug";
          utc_time = false;
        };
      });
      onChange = ''
        echo "SFTPGo config changed"
      '';
    };
    ".config/sftpgo/templates".source = "${pkgs.sftpgo}/share/sftpgo/templates";
    ".config/sftpgo/static".source = "${pkgs.sftpgo}/share/sftpgo/static";
    ".config/sftpgo/openapi".source = "${pkgs.sftpgo}/share/sftpgo/openapi";
    ".config/ghostty/config" = {
      source = ./app-config/ghostty/config;
      onChange = ''
        echo "Ghostty config changed"
      '';
    };
    ".config/flashspace/profiles.json" = {
      source = ./app-config/flashspace/profiles.json;
      onChange = ''
        echo "Flashspace profiles changed"
      '';
    };
    ".config/flashspace/settings.json" = {
      source = ./app-config/flashspace/settings.json;
      onChange = ''
        echo "Flashspace settings changed"
      '';
    };
    ".config/karabiner/karabiner.json" = {
      source = ./app-config/karabiner/karabiner.json;
      onChange = ''
        echo "Karabiner config changed"
      '';
    };
    ".wezterm.lua" = {
      source = ./app-config/wezterm/wezterm.lua;
      onChange = ''
        echo "WezTerm config changed"
      '';
    };
    ".hammerspoon/home.toml" = {
      source = ./app-config/hammerflow/home.toml;
      onChange = ''
        echo "Hammerspoon home config changed"
      '';
    };
    ".hammerspoon/init.lua" = {
      source = ./app-config/hammerflow/init.lua;
      onChange = ''
        echo "Hammerspoon init config changed"
      '';
    };
  };

  home.sessionPath = [
    "$HOME/go/bin"
  ];

  xdg.enable = true;

  imports = [ ./programs ];
}
