{ config, pkgs, ... }:

let
  watchScript = pkgs.writeShellApplication {
    name = "watch-dev-sets";
    runtimeInputs = [ pkgs.socat pkgs.jq ];
    text = ''
      # Écoute les closewindow du socket Hyprland
      # Quand un workspace *-code se vide → ferme tout le set + nettoie le socket neovide

      socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

      close_set() {
        local proj="$1"
        for suffix in lazygit opencode; do
          while IFS= read -r pid; do
            [[ -n "$pid" ]] && kill "$pid" 2>/dev/null
          done < <(hyprctl clients -j | jq -r --arg ws "$proj-$suffix" \
            '.[] | select(.workspace.name == $ws) | .pid')
        done
        rm -f "$HOME/.cache/nvim/$proj.pipe"
        # Switcher vers les workspaces de base (les workspaces du set vides seront auto-détruits)
        hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-6" })'
        hyprctl dispatch 'hl.dsp.focus({ workspace = "name:monitor" })'
        hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-5" })'
        hyprctl dispatch 'hl.dsp.focus({ workspace = "name:slack" })'
        hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-7" })'
        hyprctl dispatch 'hl.dsp.focus({ workspace = "name:web" })'
      }

      # Relance si socat se déconnecte (ex: hyprland restart)
      while true; do
        socat - "UNIX-CONNECT:$socket" 2>/dev/null | while IFS= read -r line; do
          event="''${line%%>>*}"
          [[ "$event" != "closewindow" ]] && continue

          # Chercher les workspaces *-code maintenant vides
          while IFS= read -r ws; do
            [[ -z "$ws" ]] && continue
            close_set "''${ws%-code}"
          done < <(hyprctl workspaces -j | jq -r \
            '.[] | select(.name | endswith("-code")) | select(.windows == 0) | .name')
        done
        sleep 2
      done
    '';
  };
in
{
  home.packages = [ watchScript ];
}
