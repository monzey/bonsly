{ pkgs, ... }:

pkgs.buildFHSEnv {
  name = "opencode-fhs";

  targetPkgs = pkgs: with pkgs; [
    nodejs_22
    bash
    curl
    git
    stdenv.cc.cc.lib
    gnupg
    direnv
  ];

  runScript = ''
    bash -c '
      export OPENCODE_HOME="$HOME/.opencode-npm"
      export PATH="$PATH:$OPENCODE_HOME/bin"
      export npm_config_prefix="$OPENCODE_HOME"

      if ! command -v opencode >/dev/null 2>&1; then
        echo "[+] Installation de opencode-ai@1.1.51 dans $OPENCODE_HOME..."
        npm install -g opencode-ai@1.1.51
      fi

      exec opencode "$@"
    ' bash "$@"
  '';
}
