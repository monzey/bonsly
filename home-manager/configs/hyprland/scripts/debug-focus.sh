#!/usr/bin/env bash

# Debug/Front focus: SUPER+CTRL+Z
# DP-6 (gauche)  → WS7  (debugger / devtools)
# DP-7 (milieu)  → WS8  (test / firefox devedition)
# DP-5 (droite)  → inchangé (opencode)

hyprctl dispatch moveworkspacetomonitor 7 DP-6
hyprctl dispatch moveworkspacetomonitor 8 DP-7

hyprctl dispatch focusmonitor DP-6
hyprctl dispatch workspace 7
hyprctl dispatch focusmonitor DP-7
hyprctl dispatch workspace 8

# Lancer firefox devedition si rien sur WS8 et WS7
wins=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == 8 or .workspace.id == 7)] | length")
[ "$wins" -eq 0 ] && hyprctl dispatch exec "[workspace 8 silent] firefox-devedition --devtools"
