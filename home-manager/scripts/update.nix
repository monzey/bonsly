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

    resolve_home_manager_flake() {
      if [ -n "''${BONSLY_FLAKE:-}" ]; then
        candidate="''${BONSLY_FLAKE%/}"

        if [ -f "$candidate/flake.nix" ]; then
          printf '%s\n' "$candidate"
          return 0
        fi

        if [ -f "$candidate/home-manager/flake.nix" ]; then
          printf '%s\n' "$candidate/home-manager"
          return 0
        fi

        echo "BONSLY_FLAKE ne contient pas de flake Home Manager: $candidate" >&2
        return 1
      fi

      candidate="$PWD"
      while [ "$candidate" != "/" ]; do
        if [ -f "$candidate/home-manager/flake.nix" ]; then
          printf '%s\n' "$candidate/home-manager"
          return 0
        fi

        if [ "''${candidate##*/}" = "home-manager" ] && [ -f "$candidate/flake.nix" ]; then
          printf '%s\n' "$candidate"
          return 0
        fi

        candidate="''${candidate%/*}"
        [ -n "$candidate" ] || candidate="/"
      done

      if [ -f "$HOME/.config/home-manager/flake.nix" ]; then
        printf '%s\n' "$HOME/.config/home-manager"
        return 0
      fi

      echo "Flake Home Manager introuvable." >&2
      echo "Lance update depuis le dépôt bonsly ou définis BONSLY_FLAKE." >&2
      return 1
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
      flake_path=$(resolve_home_manager_flake)
      echo "Mise à jour de Home Manager..."
      home-manager switch --flake "$flake_path#${config.home.username}"
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
