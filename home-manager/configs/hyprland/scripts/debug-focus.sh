#!/usr/bin/env bash

# Debug/Front focus: SUPER+CTRL+Z
# DP-6 (gauche)  → WS7  (debugger / devtools)
# DP-7 (milieu)  → WS8  (test / firefox devedition)
# DP-5 (droite)  → inchangé (opencode)

hyprctl dispatch 'hl.dsp.workspace.move({ workspace = 7, monitor = "DP-6" })'
hyprctl dispatch 'hl.dsp.workspace.move({ workspace = 8, monitor = "DP-7" })'

# Déplacer les DevTools déjà ouverts vers WS7
hyprctl clients -j | jq -r '.[] | select(.class == "firefox-devedition") | select(.title | test("Developer Tools")) | .address' \
  | while read -r addr; do
    hyprctl dispatch "hl.dsp.window.move({ workspace = 7, follow = false, window = \"address:$addr\" })"
  done

hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-6" })'
hyprctl dispatch 'hl.dsp.focus({ workspace = 7 })'
hyprctl dispatch 'hl.dsp.focus({ monitor = "DP-7" })'
hyprctl dispatch 'hl.dsp.focus({ workspace = 8 })'

# Lancer firefox devedition si rien sur WS8 et WS7
wins=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == 8 or .workspace.id == 7)] | length")
[ "$wins" -eq 0 ] && hyprctl dispatch 'hl.dsp.exec_cmd("[workspace 8; silent] firefox-devedition --devtools")'
