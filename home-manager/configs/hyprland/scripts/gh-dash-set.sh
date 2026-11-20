#!/usr/bin/env bash
set -euo pipefail

mode="${1:-focus}"
[[ "$mode" == focus || "$mode" == claude ]] || exit 1
state_dir="${XDG_CACHE_HOME:-$HOME/.cache}/hypr"
mkdir -p "$state_dir"
exec 9>"$state_dir/gh-dash-set.lock"
flock -w 30 9

dispatch() {
  hyprctl dispatch "$1" >/dev/null
}

lua_string() {
  jq -cn --arg value "$1" '$value'
}

monitors=$(hyprctl monitors -j)
focused=$(jq -c '.[] | select(.focused)' <<<"$monitors")
if [[ "$mode" == claude ]] && ! jq -e \
  '.activeWorkspace | .id == 9 or .name == "rg-claude"' <<<"$focused" >/dev/null; then
  exec code /home/monzey/bonsly
fi

# The laptop panel can remain enabled alongside the three desk monitors.
if jq -e 'length >= 3 and any(.[]; .name == "DP-7") and any(.[]; .name == "DP-5")' \
  <<<"$monitors" >/dev/null; then
  middle=DP-7
  claude_workspace="name:rg-claude"
else
  middle=$(jq -r '.name' <<<"$focused")
  claude_workspace="special:rg-claude"
fi

ensure_window() {
  local class="$1" workspace="$2" window command attempt
  shift 2
  window=$(hyprctl clients -j | jq -r --arg class "$class" \
    '[.[] | select(.class == $class)][0].address // empty')
  if [[ -z "$window" ]]; then
    printf -v command '%q ' "$@"
    dispatch "hl.dsp.exec_cmd($(lua_string "$command"), { workspace = $(lua_string "$workspace silent") })"
    for ((attempt = 0; attempt < 100; attempt++)); do
      window=$(hyprctl clients -j | jq -r --arg class "$class" \
        '[.[] | select(.class == $class)][0].address // empty')
      [[ -z "$window" ]] || break
      sleep 0.1
    done
    if [[ -z "$window" ]]; then
      printf 'Timed out waiting for %s.\n' "$class" >&2
      return 1
    fi
  fi
  # Move existing windows between desk and drawer without restarting the session.
  dispatch "hl.dsp.window.move({ window = $(lua_string "address:$window"), workspace = $(lua_string "$workspace"), follow = false })"
}

ensure_window gh-dash 9 kitty --class gh-dash --directory "$HOME/rg" -e gh dash
ensure_window rg-claude "$claude_workspace" kitty --class rg-claude --directory "$HOME/rg" --hold claude
dispatch "hl.dsp.workspace.move({ workspace = 9, monitor = $(lua_string "$middle") })"

hide_drawer() {
  local special
  special=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .specialWorkspace.name // empty')
  [[ -z "$special" ]] || dispatch "hl.dsp.workspace.toggle_special($(lua_string "${special#special:}"))"
}

if [[ "$claude_workspace" == name:* ]]; then
  dispatch 'hl.dsp.workspace.move({ workspace = "name:rg-claude", monitor = "DP-5" })'
  dispatch 'hl.dsp.focus({ monitor = "DP-5" })'
  hide_drawer
  dispatch 'hl.dsp.focus({ workspace = "name:rg-claude" })'
  [[ "$mode" != claude ]] || exit 0
else
  # A second press hides Claude and returns keyboard focus to gh dash.
  special=$(jq -r '.specialWorkspace.name // empty' <<<"$focused")
  if [[ "$mode" == claude && "$special" == special:rg-claude ]]; then
    dispatch 'hl.dsp.workspace.toggle_special("rg-claude")'
    exit 0
  fi
fi

dispatch "hl.dsp.focus({ monitor = $(lua_string "$middle") })"
hide_drawer
dispatch 'hl.dsp.focus({ workspace = 9 })'
if [[ "$mode" == claude ]]; then
  dispatch 'hl.dsp.workspace.toggle_special("rg-claude")'
fi
