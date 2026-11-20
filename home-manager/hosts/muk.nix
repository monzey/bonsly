{ lib, pkgs, ... }:

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
}
