{ config, pkgs, ... }:

let
  nvScript = pkgs.writeShellScriptBin "nv" ''
    #!/usr/bin/env bash
    neovide "$@"
  '';
in
{
  home.packages = [ nvScript ];
}

