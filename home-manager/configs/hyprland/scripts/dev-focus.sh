#!/usr/bin/env bash

# Dev focus layout: SUPER+CTRL+O
# DP-6 (gauche)  → WS11 lazygit-focus  (persistent:false)
# DP-7 (milieu)  → WS2  code
# DP-5 (droite)  → WS12 opencode-focus (persistent:false)

# Positionner les workspaces sur les bons écrans
hyprctl dispatch moveworkspacetomonitor 11 DP-6
hyprctl dispatch moveworkspacetomonitor 2 DP-7
hyprctl dispatch moveworkspacetomonitor 12 DP-5

# Switcher chaque écran sur son workspace
hyprctl dispatch focusmonitor DP-6
hyprctl dispatch workspace 11
hyprctl dispatch focusmonitor DP-5
hyprctl dispatch workspace 12
hyprctl dispatch focusmonitor DP-7
hyprctl dispatch workspace 2

# Lancer les apps si les workspaces sont vides
wins=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == 11)] | length")
[ "$wins" -eq 0 ] && hyprctl dispatch exec "[workspace 11 silent] kitty --hold zsh -c 'lazygit'"

wins=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == 2)] | length")
[ "$wins" -eq 0 ] && hyprctl dispatch exec "[workspace 2 silent] nv"

wins=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == 12)] | length")
[ "$wins" -eq 0 ] && hyprctl dispatch exec "[workspace 12 silent] kitty --hold zsh -c 'opencode-fhs'"
