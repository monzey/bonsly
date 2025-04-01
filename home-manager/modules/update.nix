{ config, pkgs, ... }:

let
  updateScript = pkgs.writeShellScriptBin "update" ''
    #!/bin/sh
    set -e

    usage() {
      echo "Usage: update [-h] [-r] [-s]"
      echo "  -h  Update Home Manager only"
      echo "  -r  Reload Hyprland only"
      echo "  -s  Update NixOS system only"
      exit 1
    }

    if [ $# -eq 0 ]; then
      usage
    fi

    while getopts "hrs" opt; do
      case $opt in
        h)
          echo "Mise à jour de Home Manager..."
          home-manager switch
          exit 0
          ;;
        r)
          echo "Reloading Hyprland..."
          hyprctl reload
          exit 0
          ;;
        s)
          if [ -f "/etc/NIXOS" ]; then
            flake_path="$HOME/bonsly/nixos"
            echo "Mise à jour de NixOS..."
            sudo nixos-rebuild switch --flake $flake_path#$(hostname)
          else
            echo "NixOS system not detected."
          fi
          exit 0
          ;;
        *)
          usage
          ;;
      esac
    done
  '';
in
{
  home.packages = [ updateScript ];
}
