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
        CODEX_NPM_PREFIX="$HOME/.codex-npm"
        BINARY_PATH="$CODEX_NPM_PREFIX/bin/codex"

        export npm_config_prefix="$CODEX_NPM_PREFIX"
        export PATH="$CODEX_NPM_PREFIX/bin:$PATH"

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
