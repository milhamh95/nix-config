# programs/fastfetch.nix - Fastfetch configuration
{ config, lib, pkgs, ... }:

{
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
          key = " System ";
          keyColor = "red";
        }
        {
          type = "cpu";
          key = "│ ├ CPU";
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
          key = "│ ├ Disk";
          folders = "/";
          format = "{size-used} / {size-total} ({size-percentage})";
          keyColor = "red";
        }
        {
          type = "display";
          key = "└ └ Monitor";
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
          key = " OS ";
          keyColor = "green";
        }
        {
          type = "kernel";
          key = "│ ├ ";
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
          key = " Terminal ";
          keyColor = "blue";
        }
        {
          type = "shell";
          key = "│ ├ ";
          keyColor = "blue";
        }
        {
          type = "terminalfont";
          key = "└ └ ";
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
}
