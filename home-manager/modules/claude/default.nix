{ config, lib, pkgs, ... }:

let
  claudeLauncher = pkgs.writeShellScriptBin "claude" ''
    set -euo pipefail
    executable="$HOME/.local/bin/claude"

    if [[ ! -x "$executable" ]]; then
      ${pkgs.curl}/bin/curl -fsSL https://claude.ai/install.sh | ${pkgs.bash}/bin/bash -s latest
    fi

    exec "$executable" "$@"
  '';

in
{
  home.packages = [ claudeLauncher ];

  programs.claude-code = {
    enable = true;
    package = null;
    mutableSettings = true;
    settings = lib.recursiveUpdate
      (builtins.fromJSON (builtins.readFile ../../configs/claude/settings.json))
      (lib.optionalAttrs (config.bonsly.host == "muk")
        (builtins.fromJSON (builtins.readFile ../../configs/claude/muk.json)));
  };
}
