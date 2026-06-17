{ config, lib, pkgs, ... }:

let
  cfg = config.programs.copilot-cli;

  copilotWrapper = pkgs.buildFHSEnv {
    name = "copilot-fhs";

    targetPkgs = pkgs: with pkgs; [
      nodejs_22
      bash
      curl
      git
      stdenv.cc.cc.lib
      gnupg
    ];

    runScript = ''
      bash -c '
        export COPILOT_HOME="$HOME/.copilot-cli-npm"
        export PATH="$PATH:$COPILOT_HOME/bin"
        export npm_config_prefix="$COPILOT_HOME"

        WANTED_VERSION="${cfg.version}"
        INSTALLED_VERSION=$(cat "$COPILOT_HOME/.version" 2>/dev/null || echo "")

        if [ "$INSTALLED_VERSION" != "$WANTED_VERSION" ]; then
          echo "[+] (Re)installation de @github/copilot@$WANTED_VERSION dans $COPILOT_HOME..."
          npm install -g @github/copilot@$WANTED_VERSION
          echo "$WANTED_VERSION" > "$COPILOT_HOME/.version"
        fi

        exec copilot "$@"
      ' bash "$@"
    '';
  };
in
{
  options.programs.copilot-cli = {
    version = lib.mkOption {
      type = lib.types.str;
      default = "1.0.63";
      description = "Version of @github/copilot to install via npm";
    };
  };

  config = {
    home.packages = [ copilotWrapper ];
  };
}
