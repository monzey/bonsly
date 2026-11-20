#!/usr/bin/env bash
set -euo pipefail

# Accept either the source shell directory or <package>/share/caelestia-shell.
shell_dir="${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)}"
openvide="$shell_dir/openvide"
for file in scripts/openvide.sh scripts/agent-menu.sh profiles/neovim.lua profiles/lazygit.yml; do
  [[ -r "$openvide/$file" ]]
done
[[ -r "$shell_dir/modules/openvide/Wrapper.qml" ]]
[[ -r "$shell_dir/modules/openvide/services/Projects.qml" ]]

temporary=$(mktemp -d)
trap 'rm -rf -- "$temporary"' EXIT
mkdir -p "$temporary/bin" "$temporary/home/fixture"
cat > "$temporary/bin/hyprctl" <<'MOCK'
#!/usr/bin/env bash
case "$1" in
  monitors) printf '[{},{}]\n' ;;
  workspaces) printf '[{"name":"fixture-code"}]\n' ;;
  dispatch) printf '%s\n' "$2" >> "$OPENVIDE_TEST_DISPATCH" ;;
  *) exit 1 ;;
esac
MOCK
chmod +x "$temporary/bin/hyprctl"
export PATH="$temporary/bin:$PATH"
export HOME="$temporary/home" XDG_CACHE_HOME="$temporary/cache"
export OPENVIDE_TEST_DISPATCH="$temporary/dispatch"

bash "$openvide/scripts/agent-menu.sh" --list | jq -e 'any(.[]; .value == "codex")' >/dev/null
bash "$openvide/scripts/openvide.sh" --list-sets | jq -e 'any(.[]; .value == "fixture")' >/dev/null
bash "$openvide/scripts/openvide.sh" --open-project fixture codex
[[ $(< "$temporary/dispatch") == *'name:fixture-code'* ]]
jq -e --arg directory "$HOME/fixture" '.directory == $directory' \
  "$XDG_CACHE_HOME/caelestia/openvide/fixture.json" >/dev/null

if [[ -d "$openvide/bin" ]]; then
  [[ -x "$openvide/bin/openvide-codex" && -x "$openvide/bin/lazygit" ]]
  if result=$("$openvide/bin/openvide-codex" send "$HOME/fixture" --window-pid "$$" <<< '' 2>&1); then
    echo 'Expected an empty Codex task to be rejected' >&2
    exit 1
  fi
  [[ "$result" == *'Task message is empty'* ]]
fi
echo 'PASS: QML namespace, profiles, helper discovery, set reuse and packaged binaries'
