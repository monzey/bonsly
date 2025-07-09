{ config, pkgs, ... }:

let
  nvScript = pkgs.writeShellScriptBin "nv" ''
    #!/usr/bin/env bash
    # Script to launch nvim with Kitty padding temporarily set to 0
    set -e
    win_id=$(kitty @ ls | grep -m1 '"id":' | head -1 | sed 's/[^0-9]*//g')
    kitty @ set-spacing padding=0
    nvim "$@"
    kitty @ set-spacing padding=10
  '';
in
{
  home.packages = [ nvScript ];
}

