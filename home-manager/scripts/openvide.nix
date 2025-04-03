{ config, pkgs, ... }:

let
  updateScript = pkgs.writeShellScriptBin "openvide" ''
    #!/bin/bash
    selection=$(cd ~ && find . -maxdepth 3 -type d | dmenu | xargs)
    if [[ -n "$selection" ]]; then
      code "$selection"
    fi
  '';
in
{
  home.packages = [ updateScript ];
}
