# hosts/alami-mbp/homebrew.nix - Alami MacBook Pro only Homebrew apps
{ config, lib, pkgs, ... }:

{
  homebrew = {
    # Laptop-shared casks (batfi) are in profiles/laptop/
  };
}
