# AGENTS.md — bonsly dotfiles

## Agent instructions
After any change to this repo: update this file if affected entry points, paths, or conventions have changed.

NixOS + Home Manager dotfiles repo with the customised Caelestia desktop shell. No DB or package.json.
Two configuration flakes (`nixos/`, `home-manager/`) plus the local Caelestia package flake. One user: `monzey`, machine: `muk`.

## Repo map

```
nixos/                        ← NixOS system config (root-level, requires sudo)
  flake.nix                   ← system flake entry point
  configuration.nix           ← services, boot, users, hardware
  hardware-configuration.nix  ← do not edit manually

home-manager/                 ← user-level config (no sudo)
  flake.nix                   ← HM flake entry point
  home.nix                    ← aggregates all modules + packages
  modules/                    ← zsh, hyprland, rofi, AI CLI tools (Antigravity, Codex, Copilot, Grok, OpenCode, Caveman)
  scripts/                    ← nix-wrapped shell scripts (update, merge, etc.)
  configs/                    ← per-tool dotfiles, symlinked into ~/.config/
    antigravity/              ← Antigravity CLI keybindings
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
  nix/default.nix             ← shell/native components, CodeDiff and Lazygit patches
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
| Edit monitor layout | `home-manager/configs/hyprland/hyprland.lua` (monitor + workspace rules) |
| Edit screen sharing portal | `home-manager/configs/hyprland/xdph.conf` |
| Edit Neovim plugin | `home-manager/configs/nvim/lua/plugins/<name>.lua` |
| Edit Neovim options/keymaps | `home-manager/configs/nvim/lua/config/` |
| Edit opencode config | `home-manager/configs/opencode/opencode.json` |
| Edit Codex CLI wrapper | `home-manager/modules/codex/default.nix` |
| Edit Grok CLI wrapper | `home-manager/modules/grok/default.nix` |
| Edit global caveman skills | `home-manager/modules/caveman/default.nix` |
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

- Nix flakes: `home-manager/` and `nixos/` are independent — changes to one don't require rebuilding the other
- `configs/` dirs are symlinked to `~/.config/<tool>/` via Home Manager `xdg.configFile` or `home.file`
- `Super + G` invokes `caelestia-ipc openvide git`; project-aware Git toggling and focus restoration live in `desktop/caelestia/`.
- `Super + X` invokes `caelestia-ipc openvide terminal` for a persistent Kitty drawer per Openvide set, rooted in its repository/worktree. Shared Git/terminal toggling and focus restoration live in `desktop/caelestia/services/Hypr.qml`; creation and repository lookup live in `desktop/caelestia/assets/openvide.sh`.
- Openvide selects the coding agent before creating a worktree or opening set windows. The picker flow is in `desktop/caelestia/modules/openvide/services/Projects.qml`; `assets/openvide.sh` receives the selected agent when opening a project or creating a worktree.
- Home Manager's `shell` input is `path:../desktop/caelestia` (requires Nix >= 2.26). Shell edits are built locally with `update -h`; no separate Shell push or lock revision bump is needed. Add new files to Git before building.
- Caelestia is a full-history Git subtree. From a clean Bonsly root, merge upstream with `git subtree pull --prefix=desktop/caelestia https://github.com/caelestia-dots/shell.git main`; review conflicts/dependencies and build Home Manager afterward. Keep the upstream license and subtree history.
- Shell dependencies remain pinned in `home-manager/flake.lock`; the subtree's own lock is for standalone development. Avoid updating unrelated inputs. Native build revisions are hashes of filtered component sources, independent of Bonsly's Git HEAD.
- Caelestia's `shell.json` and `shell-tokens.json` are managed as standard Home Manager files and are therefore read-only at runtime
- Scripts live as `.nix` files (wrapped with `pkgs.writeShellScriptBin`) in `home-manager/scripts/`, exported as packages in `home.nix`
- Git uses `~/.config/git/hooks` globally; `commit-msg` removes all `Co-authored-by` trailers
- `update -h` and `update -s` resolve their flakes dynamically; `BONSLY_FLAKE` can point to the repo root, `home-manager/`, or `nixos/`
- Pinned packages (e.g. lazygit v0.48.0) use `pkgs.unstable` or manual `fetchurl` overrides in `home.nix`
- Third-party agent skills are pinned with `fetchFromGitHub` (`sparseCheckout` of the skill dirs) and linked with `home.file`. Same store path into `~/.agents/skills`, `~/.grok/skills` and `~/.claude/skills`. Parents stay unmanaged. Read-only at runtime. Bump `rev` + `hash` in the module to update.
- opencode runs in an FHS env (see `home-manager/opencode-bin.nix`)

## Ignore

- `animate/` (rain animation assets, not config)
- `nixos/hardware-configuration.nix` (auto-generated)
- `home-manager/flake.lock`, `nixos/flake.lock` (lockfiles, update with `nix flake update`)
- `preview.png`, `wall.png`, `recdsk` (assets/scripts unrelated to config)
- `home-manager/configs/cursor/` (binary cursor theme assets)
- `home-manager/configs/nvim/lua/plugins/dart.lua`, `php.lua` (language plugins, rarely touched)
