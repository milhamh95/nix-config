{ config, lib, pkgs, ... }:

{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    globalConfig = {
      settings = {
        experimental = false;
        verbose = false;
        disable_tools = ["node"];
      };
      tools = {
        node = ["latest" "lts"];
        go = ["1.24.6" "latest"];
      };
    };
  };
}