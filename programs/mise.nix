{ config, lib, pkgs, ... }:

{
  programs.mise = {
    enable = false;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {
      experimental = false;
      verbose = false;
      auto_install = true;
    };

    globalConfig = {
      tools = {
        node = ["latest"];
        go = ["latest"];
      };
    };
  };
}