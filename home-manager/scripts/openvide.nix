{ config, pkgs, ... }:

let
  updateScript = pkgs.writeShellScriptBin "openvide" ''
    #!/bin/bash
    selection=$(cd ~ && find . -maxdepth 3 -type d | dmenu)
    if [[ -n "$selection" ]]; then
      kitty --working-directory="$selection" nv
    fi
  '';
in
{
  home.packages = [ updateScript ];
}
