#!/usr/bin/env bash

# Debug/Front focus: SUPER+CTRL+Z
# DP-6 (gauche)  -> WS7  (debugger / devtools)
# DP-7 (milieu)  -> WS8  (test / chromium)
# DP-5 (droite)  → inchangé (opencode)

browser=chromium
url=https://dashboard.rg-supervision.local

move_devtools() {
  hyprctl clients -j | jq -r '.[]
    | select(.class | test("^(chromium|google-chrome|Google-chrome|chrome)$"))
    | select(.title | test("DevTools|Developer Tools"))
    | .address' |
    while read -r addr; do
      hyprctl dispatch "hl.dsp.window.move({ workspace = 7, follow = false, window = \"address:$addr\" })"
    done
}

# Positionner les workspaces sur les bons écrans.
hyprctl dispatch 'hl.dsp.workspace.move({ workspace = 7, monitor = "DP-6" })'
hyprctl dispatch 'hl.dsp.workspace.move({ workspace = 8, monitor = "DP-7" })'

# Déplacer les DevTools déjà ouverts vers WS7.
move_devtools

# Switcher chaque écran sur son workspace.
hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-6" })'
hyprctl dispatch 'hl.dsp.focus({ workspace = 7 })'
hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-7" })'
hyprctl dispatch 'hl.dsp.focus({ workspace = 8 })'

# Lancer chromium si WS8 est vide.
wins=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == 8)] | length")
if [ "$wins" -eq 0 ]; then
  hyprctl dispatch "hl.dsp.exec_cmd(\"[workspace 8 silent] $browser --remote-debugging-port=9222 --auto-open-devtools-for-tabs $url\")"
  sleep 1
  move_devtools
fi
