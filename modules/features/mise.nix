{
  den.aspects.mise.homeManager.programs.mise = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    globalConfig = {
      settings = {
        experimental = false;
        verbose = false;
      };
      tools = {
        go = [ "latest" "1.25.1" ];
        erlang = "latest";
        elixir = "latest";
        node = [ "latest" "lts" ];
        bun = "latest";
        deno = "latest";
        "npm:yarn" = "latest";
        pnpm = "latest";
        uv = "latest";
        rust = "latest";
        java = [
          "temurin-21.0.11" # default — matches old SDKMAN version
          "temurin-17.0.20"
          "temurin-25.0.4"
        ];
        maven = [
          "latest"
          "3.9.15"
        ];
      };
    };
  };
}
