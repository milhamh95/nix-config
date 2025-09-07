{ config, lib, pkgs, ... }:

{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {
      experimental = false;
      verbose = false;
      auto_install = true;
    };

    globalConfig = {
      tools = {
        node = ["latest" "lts"];
        go = ["latest" "1.24.6"];
      };
    };
  };
}