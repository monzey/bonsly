{ config, lib, pkgs, ... }:

let
  cfg = config.programs.copilot-cli;

  copilotWrapper = pkgs.buildFHSEnv {
    name = "copilot";

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
        COPILOT_NPM_PREFIX="$HOME/.copilot-cli-npm"
        BINARY_PATH="$COPILOT_NPM_PREFIX/bin/copilot"

        export PATH="$COPILOT_NPM_PREFIX/bin:$PATH"
        export npm_config_prefix="$COPILOT_NPM_PREFIX"

        WANTED_VERSION="${cfg.version}"
        INSTALLED_VERSION=$(cat "$COPILOT_NPM_PREFIX/.version" 2>/dev/null || echo "")

        if [ "$INSTALLED_VERSION" != "$WANTED_VERSION" ]; then
          echo "[+] (Re)installation de @github/copilot@$WANTED_VERSION dans $COPILOT_NPM_PREFIX..."
          npm install -g @github/copilot@$WANTED_VERSION
          echo "$WANTED_VERSION" > "$COPILOT_NPM_PREFIX/.version"
        fi

        exec "$BINARY_PATH" "$@"
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
