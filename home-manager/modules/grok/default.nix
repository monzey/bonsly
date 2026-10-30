{ config, lib, pkgs, ... }:

let
  cfg = config.programs.grok;

  grokWrapper = pkgs.buildFHSEnv {
    name = "grok";

    targetPkgs = pkgs: with pkgs; [
      bash
      curl
      coreutils
      gawk
      git
      gnugrep
      gnused
      gzip
      stdenv.cc.cc.lib
      zlib
      zstd
    ];

    runScript = ''
      bash -c '
        export GROK_HOME="$HOME/.grok"
        export GROK_BIN_DIR="$GROK_HOME/bin"
        BINARY_PATH="$GROK_BIN_DIR/grok"

        export PATH="$GROK_BIN_DIR:$PATH"

        WANTED_VERSION="${lib.optionalString (cfg.version != null) cfg.version}"
        INSTALLED_VERSION=$(cat "$GROK_HOME/.version" 2>/dev/null || echo "")

        if [ -n "$WANTED_VERSION" ]; then
          if [ ! -x "$BINARY_PATH" ] || [ "$INSTALLED_VERSION" != "$WANTED_VERSION" ]; then
            echo "[+] (Re)installation de Grok Build CLI ($WANTED_VERSION)..."
            curl -fsSL https://x.ai/cli/install.sh | SHELL=/bin/sh bash -s "$WANTED_VERSION"
            echo "$WANTED_VERSION" > "$GROK_HOME/.version"
          fi
        elif [ ! -x "$BINARY_PATH" ]; then
          echo "[+] Installation de Grok Build CLI (grok)..."
          curl -fsSL https://x.ai/cli/install.sh | SHELL=/bin/sh bash
        fi

        exec "$BINARY_PATH" "$@"
      ' bash "$@"
    '';
  };
in
{
  options.programs.grok = {
    version = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional version of Grok Build CLI to install (defaults to latest stable)";
    };
  };

  config = {
    home.packages = [ grokWrapper ];

    # The upstream installer may put symlinks here, ahead of the
    # Nix profile in PATH. Keep this command managed by Home Manager instead.
    home.file.".local/bin/grok" = {
      source = "${grokWrapper}/bin/grok";
      force = true;
    };
  };
}
