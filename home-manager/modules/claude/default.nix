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

  declaredSettings = pkgs.writeText "claude-settings.json" (builtins.toJSON (
    { autoUpdatesChannel = "latest"; }
    // lib.optionalAttrs (config.bonsly.host == "muk")
      (builtins.fromJSON (builtins.readFile ../../configs/claude/muk.json))
  ));
in
{
  home.packages = [ claudeLauncher ];

  # Leave the native launcher's symlink mutable so Anthropic can update it.
  home.activation.claudeSettings = config.lib.dag.entryAfter [ "linkGeneration" ] ''
    run ${pkgs.writeShellScript "merge-claude-settings" ''
      set -euo pipefail
      settings=${config.home.homeDirectory}/.claude/settings.json
      mkdir -p "$(dirname "$settings")"
      input=/dev/null
      if [[ -e "$settings" ]]; then
        input="$settings"
      fi
      temporary=$(mktemp "$settings.XXXXXX")
      trap 'rm -f "$temporary"' EXIT
      ${pkgs.jq}/bin/jq -s -f ${./merge-settings.jq} \
        "$input" ${declaredSettings} > "$temporary"
      mv "$temporary" "$settings"
    ''}
  '';
}
