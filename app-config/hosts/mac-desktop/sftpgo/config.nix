{ pkgs }:

let
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
}
