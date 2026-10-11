{ pkgs, ... }:

let
  antigravityWrapper = pkgs.buildFHSEnv {
    name = "agy";

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
        AGY_HOME="$HOME/.local/share/antigravity"
        BINARY_PATH="$AGY_HOME/bin/agy"

        if [ ! -x "$BINARY_PATH" ]; then
          echo "[+] Installation de antigravity CLI (agy)..."
          curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- --dir "$AGY_HOME/bin"
        fi

        exec "$BINARY_PATH" "$@"
      ' bash "$@"
    '';
  };
in
{
  config = {
    home.packages = [ antigravityWrapper ];

    # The upstream installer previously put the real binary here, ahead of the
    # Nix profile in PATH. Keep this command managed by Home Manager instead.
    home.file.".local/bin/agy" = {
      source = "${antigravityWrapper}/bin/agy";
      force = true;
    };

    home.file.".gemini/antigravity-cli/keybindings.json" = {
      source = ../../configs/antigravity/keybindings.json;
    };
  };
}
