{ pkgs, ... }:

pkgs.buildFHSEnv {
  name = "cleanup";
  runScript = ''
    bash -c '
      set -euo pipefail

      echo "--- Nettoyage de Home Manager (plus de 30 jours) ---"
      home-manager expire-generations "-30 days"

      echo "--- Nettoyage des générations utilisateur (plus de 30 jours) ---"
      nix-env --delete-generations 30d

      echo "--- Nettoyage des générations système et du store ---"
      sudo nix-collect-garbage --delete-older-than 30d

      echo "--- Nettoyage terminé ! ---"
    ' bash "$@"
  '';
}
