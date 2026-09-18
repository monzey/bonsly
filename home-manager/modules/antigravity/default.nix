{ pkgs, ... }:

let
  antigravityWrapper = pkgs.buildFHSEnv {
    name = "agy-fhs";

    targetPkgs = pkgs: with pkgs; [
      bash
      curl
      coreutils
      gnutar
      git
      stdenv.cc.cc.lib
      gnused
    ];

    runScript = ''
      bash -c '
        BINARY_PATH="$HOME/.local/bin/agy"

        if [ ! -f "$BINARY_PATH" ]; then
          echo "[+] Installation de antigravity CLI (agy)..."
          curl -fsSL https://antigravity.google/cli/install.sh | bash
        fi

        exec "$BINARY_PATH" "$@"
      ' bash "$@"
    '';
  };
in
{
  config = {
    home.packages = [ antigravityWrapper ];
  };
}
