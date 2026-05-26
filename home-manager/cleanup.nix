{ pkgs, ... }:

pkgs.buildFHSEnv {
  name = "cleanup";
  runScript = ''
    bash -c '
      echo "--- Nettoyage des anciennes générations (Root) ---"
      sudo nix-collect-garbage -d

      echo "--- Nettoyage des anciennes générations (Utilisateur) ---"
      nix-collect-garbage -d

      echo "--- Nettoyage de Home Manager ---"
      home-manager expire-generations "-0 days"

      echo "--- Optimisation du store (Hardlinks) ---"
      nix-store --optimise

      echo "--- Nettoyage terminé ! ---"
    ' bash "$@"
  '';
}
