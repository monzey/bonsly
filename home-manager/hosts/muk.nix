{ config, pkgs, ... }:

{
  imports = [ ../home.nix ];
  bonsly.host = "muk";

  # Keep Claude's mutable plugin state while persisting user permissions.
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
      ${pkgs.jq}/bin/jq -s '
        (.[0] // {})
        | .permissions.allow = (((.permissions.allow // []) + [
            "WebFetch(domain:*.dashboard.rg-supervision.local)",
            "Bash(npx playwright *)",
            "Bash(playwright *)"
          ]) | unique)
        | .sandbox.network.allowedDomains = (((.sandbox.network.allowedDomains // []) + [
            "*.dashboard.rg-supervision.local"
          ]) | unique)
      ' "$input" > "$temporary"
      mv "$temporary" "$settings"
    ''}
  '';
}
