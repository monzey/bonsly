# AGENTS.md — bonsly dotfiles

## Agent instructions
After any change to this repo: update this file if affected entry points, paths, or conventions have changed.

NixOS + Home Manager dotfiles repo with the customised Caelestia desktop shell. No DB or package.json.
Two configuration flakes (`nixos/`, `home-manager/`) plus the local Caelestia package flake. One user: `monzey`; hosts: `muk` (development, Intel) and `gardevoir` (home, AMD/NVIDIA).

## Repo map

```
nixos/                        ← NixOS system config (root-level, requires sudo)
  flake.nix                   ← system flake entry point
  configuration.nix           ← shared services, boot, users
  hosts/<host>/default.nix    ← hostname, GPU and host-specific settings
  hosts/<host>/hardware-configuration.nix ← generated per machine; do not edit manually

home-manager/                 ← user-level config (no sudo)
  flake.nix                   ← HM flake entry point
  home.nix                    ← shared modules + packages
  hosts/{muk,gardevoir}.nix   ← per-machine Home Manager entry points
  modules/                    ← zsh, hyprland, rofi, AI CLI tools (Antigravity, Codex, Copilot, Grok, OpenCode, Caveman)
  scripts/                    ← nix-wrapped shell scripts (update, merge, etc.)
  configs/                    ← per-tool dotfiles, symlinked into ~/.config/
    antigravity/              ← Antigravity CLI keybindings
    codex/                    ← shared desktop/agent guidance + per-host context
    hyprland/                 ← WM, portal, keybinds, monitor layout, scripts
    nvim/                     ← LazyVim config (lua/config/, lua/plugins/)
    opencode/                 ← opencode.json, plugins/nvim.ts
    waybar/                   ← bar config + style.css
    eww/                      ← eww.yuck + eww.scss widgets
    kitty/                    ← terminal config
    zsh -> modules/zsh.nix
    git/                      ← gitconfig + global hooks
    mcphub/                   ← MCP servers config (servers.json)

desktop/caelestia/             ← Caelestia shell subtree, full upstream/fork history
  flake.nix                   ← local shell packages + development shell
  nix/default.nix             ← shell/native components, unified.nvim and Lazygit patches
  assets/openvide*            ← project sets, Neovim profile, Git overview
  modules/, services/         ← desktop interface and IPC


animate/                      ← rain animation PNGs + shell scripts (ignore unless asked)
```

## Entry points by task

| Task | Start here |
|------|-----------|
| Add/remove system package | `nixos/configuration.nix` |
| Add/remove user package | `home-manager/home.nix` (packages list) |
| Edit shell (zsh, aliases, env) | `home-manager/modules/zsh.nix` |
| Edit keybinds / WM behaviour | `home-manager/configs/hyprland/hyprland.lua` |
| Edit monitor layout | `home-manager/configs/hyprland/hosts/{muk,gardevoir}.lua` (monitor + workspace rules) |
| Edit screen sharing portal | `home-manager/configs/hyprland/xdph.conf` |
| Edit Neovim plugin | `home-manager/configs/nvim/lua/plugins/<name>.lua` |
| Edit Neovim options/keymaps | `home-manager/configs/nvim/lua/config/` |
| Edit opencode config | `home-manager/configs/opencode/opencode.json` |
| Edit Codex CLI wrapper | `home-manager/modules/codex/default.nix` |
| Edit Codex settings and plugin choices | `~/.codex/config.toml` (managed manually and by Codex Desktop, outside Bonsly) |
| Edit global ChatGPT/Codex agent guidance | `home-manager/configs/codex/AGENTS.md` + `hosts/<host>.md` |
| Edit Grok CLI wrapper | `home-manager/modules/grok/default.nix` |
| Edit RTK agent integrations (gardevoir) | `home-manager/modules/rtk/default.nix` |
| Edit global caveman skills | `home-manager/modules/caveman/default.nix` |
| Edit shared Ponytail skill (muk + gardevoir) | `home-manager/modules/ponytail/default.nix` |
| Edit Antigravity CLI config | `home-manager/configs/antigravity/` + `home-manager/modules/antigravity/default.nix` |
| Edit Caelestia/Openvide behaviour | `desktop/caelestia/` (see its `README.md`) |
| Edit Caelestia Shell config | `home-manager/configs/caelestia/shell.json` + `shell-tokens.json` |
| Edit icon theme | `home-manager/home.nix` (`gtk.iconTheme` + Caelestia service environment) |
| Edit opencode Neovim plugin | `home-manager/configs/opencode/plugins/nvim.ts` |
| Edit bar (waybar) | `home-manager/configs/waybar/config` + `style.css` |
| Edit widgets (eww) | `home-manager/configs/eww/eww.yuck` + `eww.scss` |
| Edit Git config/hooks | `home-manager/configs/git/` |
| Edit update/merge scripts | `home-manager/scripts/<name>.nix` |
| Edit MCP servers | `home-manager/configs/mcphub/servers.json` |
| Edit NixOS services | `nixos/configuration.nix` (systemd, networking, etc.) |
| New HM module | Create `home-manager/modules/<name>.nix`, import in `home.nix` |

## Build commands

```bash
update -h       # home-manager switch --flake (resolved from cwd, BONSLY_FLAKE, or ~/.config/home-manager)
update -s       # nixos-rebuild switch --flake (resolved from cwd or BONSLY_FLAKE)
update -r       # hyprctl reload (WM only, instant)
update -hsr     # all three — standard full update
```

## Key conventions

- gardevoir mounts its ext4 data partitions by filesystem UUID at `/mnt/games` (Crucial BX500), `/mnt/media` (Toshiba MQ04UBF100) and `/mnt/misc` (Samsung 860 EVO), declared in `nixos/hosts/gardevoir/default.nix`. They use systemd automount and tolerate absent drives; ext4 ownership is stored on disk, not set through mount options.

- gardevoir disables automatic locking (idle and before sleep) through host-specific Caelestia and hypridle overrides in `home-manager/hosts/gardevoir.nix`; manual locking and other idle actions remain available.

- Spec Kit project tooling lives in `.specify/`, with Codex skills in `.agents/skills/speckit-*/` and feature artifacts in `specs/`. Commit shared tooling, manifests, configuration and feature artifacts; `.specify/.gitignore` excludes local feature selection, extension overrides and executable adapter packages.
- Host outputs: NixOS `muk` / `gardevoir`; Home Manager `monzey@muk` / `monzey@gardevoir`. `update -h` and `update -s` select by hostname; `BONSLY_HOST` explicitly overrides it. Unknown hosts fail before switching.
- `home-manager/modules/codex/default.nix` assembles common guidance and only the selected host's context into `~/.codex/AGENTS.md`. Edit its sources in `home-manager/configs/codex/`; the generated file is read-only. This is agent/Codex guidance, not an automatic replacement for ordinary ChatGPT chat custom instructions. A custom `CODEX_HOME` needs separate wiring.
- First migration: use `home-manager switch --flake ./home-manager#monzey@<host>` to install the new update script. On the home PC, whose old hostname may still be `muk`, first use `sudo nixos-rebuild switch --flake ./nixos#gardevoir` to apply the correct hardware and rename it. Never select `muk` there based on the old hostname.
- Hyprland monitor/workspace layouts live in `home-manager/configs/hyprland/hosts/<host>.lua`; `modules/hyprland.nix` prepends the selected layout to the shared `hyprland.lua`. Other Hyprland files remain symlinked.
- Host-specific autostart also lives in those Hyprland host files: `gardevoir` starts Vesktop on workspace 3 (`vesktop`, Super+Ctrl+N), Steam on workspace 4 (`ia`, Super+Ctrl+P) and ChatGPT Desktop on workspace 9 (`conf`, Super+Ctrl+S); `muk` keeps Slack on workspace 3 and Firefox's ChatGPT profile on workspace 4. Steam and Prism Launcher are installed only by `home-manager/hosts/gardevoir.nix`; The games disk replaces the former Windows F disk; use `/mnt/games` for Steam and Prism data (launcher configuration stays in the Linux home); `nixos/hosts/gardevoir/default.nix` supplies 32-bit graphics/audio and Steam hardware rules, without enabling `programs.steam`.
- Nix flakes: `home-manager/` and `nixos/` are independent — changes to one don't require rebuilding the other
- Firefox uses profile `default` on both hosts. Shared Hyprland autostart must allow remote commands (no `--no-remote`); `home-manager/home.nix` routes HTML and HTTP/HTTPS links through `firefox-default.desktop` with the same explicit profile.
- `configs/` dirs are symlinked to `~/.config/<tool>/` via Home Manager `xdg.configFile` or `home.file`
- Fontconfig is enabled in `home-manager/home.nix`; its `refreshFontCache` activation rebuilds user font caches after package installation and config linking on every Home Manager switch.
- `Super + G` invokes `caelestia-ipc openvide git`; project-aware Git toggling and focus restoration live in `desktop/caelestia/`.
- `Super + X` invokes `caelestia-ipc openvide terminal` for a persistent Kitty drawer per Openvide set, rooted in its repository/worktree. `desktop/caelestia/services/Hypr.qml` forwards Git/terminal shortcuts to `desktop/caelestia/assets/openvide.sh --toggle-tool`, which serializes them, reuses windows by class, and restores only code/agent focus. The underlying workspace defines the set; one drawer is visible at a time.
- Hyprland hides special workspaces when switching workspace. The `openvide-shortcuts` window rule prevents Openvide's Lazygit/terminal windows from inhibiting compositor shortcuts (`home-manager/configs/hyprland/hyprland.lua`).
- Openvide selects the coding agent before creating a worktree or opening set windows. The picker flow is in `desktop/caelestia/modules/openvide/services/Projects.qml`; `assets/openvide.sh` receives the selected agent when opening a project or creating a worktree.
- Openvide's compact layout applies to both one and two screens: `assets/openvide.sh` places the initial agent/editor pair at 35%/65%, agent on the right. Three or more screens keep separate workspaces; additional user windows are not rearranged.
- Unified.nvim is configured for ordinary Neovim in `home-manager/configs/nvim/lua/plugins/unified.lua` and `lua/config/unified.lua`; `<leader>gu` opens diffs against HEAD. Home Manager links the shell's pinned, patched plugins into `~/.local/share/nvim/nix-plugins`. `desktop/caelestia/assets/openvide-nvim.lua` only triggers the diff view on set startup. The shared configuration polls external edits, uses editable buffers, replaces the dashboard on opening and keeps the panel visible on selection, and provides `<leader>b`, `]h` / `[h` and `<leader>gD`. The patch in `desktop/caelestia/nix/patches/unified-no-external-diff.patch` bypasses external diff drivers. Ordinary startup leaves the diff view closed.
- Home Manager's `shell` input is `path:../desktop/caelestia` (requires Nix >= 2.26). Shell edits are built locally with `update -h`; no separate Shell push or lock revision bump is needed. Add new files to Git before building.
- Caelestia is a full-history Git subtree. From a clean Bonsly root, merge upstream with `git subtree pull --prefix=desktop/caelestia https://github.com/caelestia-dots/shell.git main`; review conflicts/dependencies and build Home Manager afterward. Keep the upstream license and subtree history.
- Shell dependencies remain pinned in `home-manager/flake.lock`; the subtree's own lock is for standalone development. Avoid updating unrelated inputs. Native build revisions are hashes of filtered component sources, independent of Bonsly's Git HEAD.
- Caelestia's `shell.json` and `shell-tokens.json` are managed as standard Home Manager files and are therefore read-only at runtime
- Scripts live as `.nix` files (wrapped with `pkgs.writeShellScriptBin`) in `home-manager/scripts/`, exported as packages in `home.nix`
- Git uses `~/.config/git/hooks` globally; `commit-msg` removes all `Co-authored-by` trailers
- `update -h` and `update -s` resolve their flakes dynamically; `BONSLY_FLAKE` can point to the repo root, `home-manager/`, or `nixos/`
- Pinned packages (e.g. lazygit v0.48.0) use `pkgs.unstable` or manual `fetchurl` overrides in `home.nix`
- Firefox stable uses `unstablePkgs.firefox` in `home-manager/home.nix`; update the Home Manager `nixos-unstable` input for browser updates.
- Third-party agent skills are pinned with `fetchFromGitHub` (Caveman uses `sparseCheckout` of the skill dirs) and linked with `home.file`. Same store path into `~/.agents/skills`, `~/.grok/skills` and `~/.claude/skills`. Parents stay unmanaged. Read-only at runtime. Bump `rev` + `hash` in the module to update. Ponytail's main skill is imported through shared `home.nix` for both hosts; its plugin, hooks and companion skills are not installed.
- opencode runs in an FHS env (see `home-manager/opencode-bin.nix`)
- gardevoir installs RTK from the pinned unstable input via `home-manager/modules/rtk/`. Its pinned binary generates Codex, OpenCode, Copilot CLI and Antigravity integration files during the build; activation merges the Claude Code hook without replacing existing settings. Grok has no RTK integration. Copilot's npm prefix is separate from its standard `~/.copilot` configuration directory; do not export that prefix as `COPILOT_HOME`.

## Ignore

- `animate/` (rain animation assets, not config)
- `nixos/hosts/*/hardware-configuration.nix` (auto-generated)
- `home-manager/flake.lock`, `nixos/flake.lock` (lockfiles, update with `nix flake update`)
- `preview.png`, `wall.png`, `recdsk` (assets/scripts unrelated to config)
- `home-manager/configs/cursor/` (binary cursor theme assets)
- `home-manager/configs/nvim/lua/plugins/dart.lua`, `php.lua` (language plugins, rarely touched)

- gardevoir exports the standard `org.freedesktop.appearance/reduced-motion` portal setting through a GTK compatibility patch in `nixos/packages/portal-gtk.nix` and `portal-gtk-reduced-motion.patch`, selected by the host overlay. It maps the existing `org.gnome.desktop.interface/enable-animations` preference (Home Manager host profile) to 0/1 and emits live changes; remove the patch when upstream provides this mapping.
- gardevoir remaps the GC101 Controller 1.03 (`20bc:5656`, revision `0111`) HID button usages to positional Linux gamepad codes via `services.udev.extraHwdb` in `nixos/hosts/gardevoir/default.nix`. This applies outside Steam, including Firefox. After activation, reconnect the controller and reconfigure any Steam custom input mapping if needed; joydev button indices may change. Axes are unchanged.
