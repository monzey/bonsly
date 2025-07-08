{ config, pkgs, ... }:

let
  updateScript = pkgs.writeShellScriptBin "update" ''
    #!/bin/sh
    set -e

    usage() {
      echo "Usage: update [-h] [-r] [-s]"
      echo "  -h  Update Home Manager"
      echo "  -r  Reload Hyprland"
      echo "  -s  Update NixOS system"
      echo "  Options can be combined (e.g. update -hrs)"
      exit 1
    }

    if [ $# -eq 0 ]; then
      usage
    fi

    update_home=false
    reload_hyprland=false
    update_system=false

    while getopts "hrs" opt; do
      case $opt in
        h)
          update_home=true
          ;;
        r)
          reload_hyprland=true
          ;;
        s)
          update_system=true
          ;;
        *)
          usage
          ;;
      esac
    done

    # Check if at least one option was provided
    if ! $update_home && ! $reload_hyprland && ! $update_system; then
      usage
    fi

    # Execute actions based on provided options
    if $update_home; then
      echo "Mise à jour de Home Manager..."
      home-manager switch
    fi

    if $reload_hyprland; then
      echo "Reloading Hyprland..."
      hyprctl reload
    fi

    if $update_system; then
      if [ -f "/etc/NIXOS" ]; then
        flake_path="$HOME/bonsly/nixos"
        echo "Mise à jour de NixOS..."
        sudo nixos-rebuild switch --flake $flake_path#$(hostname)
      else
        echo "NixOS system not detected."
      fi
    fi
  '';
in
{
  home.packages = [ updateScript ];
}
