{ pkgs, ... }:

let
  codexWrapper = pkgs.buildFHSEnv {
    name = "codex";

    targetPkgs = pkgs: with pkgs; [
      nodejs_22
      bash
      curl
      coreutils
      git
      stdenv.cc.cc.lib
    ];

    runScript = ''
      bash -c '
        CODEX_HOME="$HOME/.codex-npm"
        BINARY_PATH="$CODEX_HOME/bin/codex"

        export npm_config_prefix="$CODEX_HOME"
        export PATH="$CODEX_HOME/bin:$PATH"

        if [ ! -x "$BINARY_PATH" ]; then
          echo "[+] Installation de Codex CLI..."
          npm install -g @openai/codex
        fi

        exec "$BINARY_PATH" "$@"
      ' bash "$@"
    '';
  };
in
{
  config = {
    home.packages = [ codexWrapper ];
  };
}
