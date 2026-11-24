# Desktop configuration

Paths below are relative to the Bonsly root. For gardevoir hardware and activation checks,
see [gardevoir.md](gardevoir.md).

## Hyprland configuration

Hyprland monitor/workspace layouts live in `home-manager/configs/hyprland/hosts/<host>.lua`;
`home-manager/modules/hyprland.nix` prepends the selected layout to the shared `hyprland.lua`. Other Hyprland
files remain symlinked.

## Applications and workspaces

Host-specific autostart also lives in those Hyprland host files: `gardevoir` starts Vesktop on
workspace 3 (`vesktop`, Super+Ctrl+N), Steam on workspace 4 (`ia`, Super+Ctrl+P) and ChatGPT Desktop
on workspace 9 (`conf`, Super+Ctrl+S); `muk` keeps Slack on workspace 3, starts Codex in `~/monzey`
on workspace 4 (`ia`, Super+Ctrl+P) on the right desk screen (DP-5), ChatGPT Desktop on the named
`chatgpt` workspace on the middle desk screen (DP-7), and `gh dash` in Kitty on workspace 9
(Super+Ctrl+S). Super+Ctrl+P displays the ChatGPT workspace on DP-7 and Codex workspace 4 on DP-5,
starting either application if its workspace is empty. On muk, Super+Ctrl+S opens the gh-dash/Claude
set: gh-dash on DP-7 and a persistent Claude session rooted in `/home/monzey/rg` on DP-5 when the
desk monitors are connected (at least three screens). With fewer screens, Claude uses
`special:rg-claude`; Super+C toggles that drawer from workspace 9 and retains its ordinary VS Code
action outside the set. The host profile supplies optional `hostBindings` overrides consumed by the
shared Hyprland configuration.

`Super+Ctrl+I` opens the shared named workspace `agent`: Codex from `$HOME` on gardevoir's left
screen (DP-2), and Claude from `$HOME/rg` on muk's middle desk screen (DP-7). The shortcut reuses
the existing terminal on that workspace.

On gardevoir, Hyprland opens new windows with class `steam_app_<id>` on a dedicated `steam-<id>`
workspace on DP-1 and follows the game. The host rules live in
`home-manager/configs/hyprland/hosts/gardevoir.lua`.

## Openvide shortcuts

`Super+Ctrl+Space` opens the Openvide picker for current Steam game workspaces (`steam-<id>`).

`Super + G` invokes `caelestia-ipc openvide git`; project-aware Git toggling and focus restoration
live in `desktop/caelestia/`.

`Super + X` invokes `caelestia-ipc openvide terminal` for the current set. Openvide implementation
and invariants live in `desktop/caelestia/openvide/AGENTS.md`; `desktop/caelestia/services/Hypr.qml` is the desktop
integration point.

Hyprland hides special workspaces when switching workspace. The `openvide-shortcuts` window rule
prevents Openvide's Lazygit/terminal windows from inhibiting compositor shortcuts
(`home-manager/configs/hyprland/hyprland.lua`).

## Firefox

Firefox uses profile `default` on both hosts. Shared Hyprland autostart must allow remote commands
(no `--no-remote`); `home-manager/home.nix` routes HTML and HTTP/HTTPS links through
`firefox-default.desktop` with the same explicit profile.

Firefox stable uses `unstablePkgs.firefox` in `home-manager/home.nix`; update the Home Manager
`nixos-unstable` input for browser updates.

## Fonts

Fontconfig is enabled in `home-manager/home.nix`; its `refreshFontCache` activation rebuilds user
font caches after package installation and config linking on every Home Manager switch.

## Shared Lazygit package

Lazygit is defined once in `desktop/caelestia/nix/lazygit.nix` and exported by the local shell
flake. Home Manager and Openvide use the same patched package. Update its version/source hash and
check the Openvide patch there; no flake input update is required. The patch adds remote URLs,
worktree paths and full commit descriptions only when `OPENVIDE_GIT_OVERVIEW=1`; native
`gui.sidePanels` in `desktop/caelestia/openvide/profiles/lazygit.yml` selects worktrees/remotes. Ordinary terminal use
keeps the upstream behaviour. Package builds test presentation and configuration.

Native build revisions are hashes of filtered component sources, independent of Bonsly's Git HEAD.

For Unified.nvim, see the [Neovim README](../home-manager/configs/nvim/README.md).
