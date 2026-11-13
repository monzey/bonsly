{ config, lib, pkgs, ... }:

{
  imports = [ ../home.nix ];
  bonsly.host = "muk";
  home.packages = [ pkgs.snyk ];

  xdg.mimeApps = {
    defaultApplications = {
      "x-scheme-handler/msteams" = [ "teams-for-linux.desktop" ];
      "x-scheme-handler/figma" = [ "figma-linux.desktop" ];
      "x-scheme-handler/slack" = [ "slack.desktop" ];
      "x-scheme-handler/discord" = [ "vesktop.desktop" ];
      "x-scheme-handler/claude-cli" = [ "claude-code-url-handler.desktop" ];
      "x-scheme-handler/codex" = [ "chatgpt.desktop" ];
    } // lib.genAttrs [
      "x-scheme-handler/chrome"
      "application/xhtml+xml"
      "application/x-extension-htm"
      "application/x-extension-html"
      "application/x-extension-shtml"
      "application/x-extension-xhtml"
      "application/x-extension-xht"
    ] (_: [ "firefox-default.desktop" ]);
    associations.added = lib.genAttrs [
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/chrome"
      "text/html"
      "application/xhtml+xml"
      "application/x-extension-htm"
      "application/x-extension-html"
      "application/x-extension-shtml"
      "application/x-extension-xhtml"
      "application/x-extension-xht"
    ] (_: [ "firefox-default.desktop" ]);
  };

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
      ${pkgs.jq}/bin/jq -s -f ${../modules/claude/merge-settings.jq} \
        "$input" ${../configs/claude/muk.json} > "$temporary"
      mv "$temporary" "$settings"
    ''}
  '';
}
