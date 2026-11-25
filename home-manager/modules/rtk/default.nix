{ config, lib, pkgs, unstablePkgs, ... }:

let
  rtk = unstablePkgs.rtk;
  # Generate integrations with the pinned binary rather than copying upstream hooks.
  integrations = pkgs.runCommand "rtk-integrations-${rtk.version}" {
    nativeBuildInputs = [ rtk ];
  } ''
    export HOME="$TMPDIR/home"
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_DATA_HOME="$HOME/.local/share"
    export CODEX_HOME="$HOME/.codex"
    mkdir -p "$HOME"
    cd "$HOME"
    rtk init -g --opencode --auto-patch --no-trust-filters
    rtk init -g --codex
    rtk init -g --copilot
    rtk init -g --agent antigravity
    cp -r "$HOME" "$out"
  '';
in
{
  home.packages = [ rtk ];

  home.file = {
    ".codex/hooks.json".source = "${integrations}/.codex/hooks.json";
    ".codex/RTK.md".source = "${integrations}/.codex/RTK.md";
    ".codex/AGENTS.md".text = lib.mkAfter ''

      ## Sorties des commandes

      RTK est installé ; lire ~/.codex/RTK.md pour son utilisation.
    '';
    ".copilot/hooks/rtk-rewrite.json".source = "${integrations}/.copilot/hooks/rtk-rewrite.json";
    ".copilot/copilot-instructions.md".source = "${integrations}/.copilot/copilot-instructions.md";
    ".gemini/config/plugins/rtk".source = "${integrations}/.gemini/config/plugins/rtk";
  };
  xdg.configFile."opencode/plugins/rtk.ts".source = "${integrations}/.config/opencode/plugins/rtk.ts";

  programs.claude-code.settings.hooks.PreToolUse = [
    {
      matcher = "Bash";
      hooks = [ { type = "command"; command = "${rtk}/bin/rtk hook claude"; } ];
    }
  ];

  # Install RTK's Claude documentation after Home Manager writes the hook.
  home.activation.rtkClaude = config.lib.dag.entryAfter [ "claudeCodeSettings" ] ''
    run env PATH=${lib.makeBinPath [ rtk pkgs.coreutils pkgs.bash pkgs.git ]} \
      ${rtk}/bin/rtk init -g --auto-patch --no-trust-filters
  '';
}
