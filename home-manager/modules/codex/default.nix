{ config, pkgs, ... }:

let
  # The npm Linux binary is static musl; no FHS/Bubblewrap environment is needed.
  codexWrapper = pkgs.writeShellApplication {
    name = "codex";
    runtimeInputs = with pkgs; [ nodejs_22 bash curl coreutils git ];
    text = ''
      CODEX_NPM_PREFIX="$HOME/.codex-npm"
      BINARY_PATH="$CODEX_NPM_PREFIX/bin/codex"

      export npm_config_prefix="$CODEX_NPM_PREFIX"
      export PATH="$CODEX_NPM_PREFIX/bin:$PATH"

      if [ ! -x "$BINARY_PATH" ]; then
        echo "[+] Installation de Codex CLI..."
        npm install -g @openai/codex
      fi

      exec "$BINARY_PATH" "$@"
    '';
  };
in
{
  config = {
    home.packages = [ codexWrapper ];

    home.file.".codex/AGENTS.md".text =
      builtins.readFile ../../configs/codex/AGENTS.md
      + "\n"
      + builtins.readFile (../../configs/codex/hosts + "/${config.bonsly.host}.md");
  };
}
