{ config, pkgs, ... }:

let
  updateScript = pkgs.writeShellScriptBin "openvide" ''
    #!/bin/bash
    selection=$(cd ~ && find . -maxdepth 3 -type d | dmenu)
    if [[ -n "$selection" ]]; then
      (cd ~/"$selection" && neovide) &
      disown
    fi
  '';
in
{
  home.packages = [ updateScript ];
}
