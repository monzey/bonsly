{ config, lib, pkgs, ... }:

let
  cfg = config.programs.opencode;

  opencodeWrapper = pkgs.buildFHSEnv {
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

        WANTED_VERSION="${cfg.version}"
        INSTALLED_VERSION=$(cat "$OPENCODE_HOME/.version" 2>/dev/null || echo "")

        if [ "$INSTALLED_VERSION" != "$WANTED_VERSION" ]; then
          echo "[+] (Re)installation de opencode-ai@$WANTED_VERSION dans $OPENCODE_HOME..."
          npm install -g opencode-ai@$WANTED_VERSION
          echo "$WANTED_VERSION" > "$OPENCODE_HOME/.version"
        fi

        exec opencode "$@"
      ' bash "$@"
    '';
  };
in
{
  options.programs.opencode = {
    version = lib.mkOption {
      type = lib.types.str;
      default = "1.1.51";
      description = "Version of opencode-ai to install via npm";
    };
  };

  config = {
    home.packages = [ opencodeWrapper ];
  };
}
