{ config, lib, pkgs, ... }:

{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = false;

    globalConfig = {
      settings = {
        experimental = false;
        verbose = false;
      };
      tools = {
        go = ["latest" "1.25.1"];
        erlang = "latest";
        elixir = "latest";
        node = ["latest" "lts"];
        bun = "latest";
        deno = "latest";
        "npm:yarn" = "latest";
        pnpm = "latest";
        uv = "latest";
        rust = "latest";
      };
    };
  };
}
