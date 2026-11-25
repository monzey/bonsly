# AGENTS.md — bonsly dotfiles

## Agent instructions

Keep this file focused on repository-wide workflow, entry points and safeguards.
Update it when those change. Put tool behavior, host details and implementation notes in the
relevant documentation linked below; update that documentation when its subject changes.

NixOS + Home Manager dotfiles with a customised Caelestia shell. User: `monzey`;
hosts: `muk` (development, Intel) and `gardevoir` (home, AMD/NVIDIA).

## Repo map

```text
nixos/                System flake: configuration.nix + hosts/<host>/default.nix
home-manager/         User flake: home.nix + hosts/<host>.nix, modules/, configs/, scripts/
desktop/caelestia/    Local shell flake and full-history Git subtree
.specify/             Spec Kit tooling; feature artifacts in specs/
docs/                 Host, desktop, agent integration and migration notes
```

## Entry points by task

| Task | Start here |
|------|-----------|
| Add/remove system package | `nixos/configuration.nix` |
| Add/remove user package | `home-manager/home.nix` (packages list) |
| Add/remove host-specific user package | `home-manager/hosts/<host>.nix` |
| Edit shell (zsh, aliases, env) | `home-manager/modules/zsh.nix` |
| Edit keybinds / WM behaviour | `home-manager/configs/hyprland/hyprland.lua` |
| Edit monitor layout | `home-manager/configs/hyprland/hosts/{muk,gardevoir}.lua` (monitor + workspace rules) |
| Edit screen sharing portal | `home-manager/configs/hyprland/xdph.conf` |
| Edit Neovim plugin | `home-manager/configs/nvim/lua/plugins/<name>.lua` |
| Edit Unified.nvim | `home-manager/configs/nvim/README.md` |
| Edit Neovim options/keymaps | `home-manager/configs/nvim/lua/config/` |
| Edit opencode config | `home-manager/configs/opencode/opencode.json` |
| Edit Codex CLI wrapper | `home-manager/modules/codex/default.nix` |
| Edit Codex settings and plugin choices | `~/.codex/config.toml` (managed manually and by Codex Desktop, outside Bonsly) |
| Edit global ChatGPT/Codex agent guidance | `home-manager/configs/codex/AGENTS.md` + `home-manager/configs/codex/hosts/<host>.md` |
| Edit Grok CLI wrapper | `home-manager/modules/grok/default.nix` |
| Edit shared RTK agent integrations (muk + gardevoir) | `home-manager/modules/rtk/default.nix`, imported by `home-manager/home.nix` |
| Edit Claude Code launcher / update channel | `home-manager/modules/claude/default.nix` (shared native installation for terminal and Openvide) |
| Edit Claude Code user settings | `home-manager/configs/claude/settings.json` and `home-manager/configs/claude/muk.json`; `programs.claude-code.mutableSettings` in `home-manager/modules/claude/default.nix` |
| Edit desktop MIME associations | `home-manager/home.nix` (shared Firefox defaults) + `home-manager/hosts/{muk,gardevoir}.nix` (host handlers) |
| Edit global caveman skills | `home-manager/modules/caveman/default.nix` |
| Edit shared Ponytail skill (muk + gardevoir) | `home-manager/modules/ponytail/default.nix` |
| Edit local shared agent skills (Openvide workflow) | `home-manager/configs/skills/` + `home-manager/modules/local-skills/default.nix` |
| Edit Antigravity CLI config | `home-manager/configs/antigravity/` + `home-manager/modules/antigravity/default.nix` |
| Edit Caelestia shell behaviour | `desktop/caelestia/` (see its `README.md`) |
| Edit Openvide sets, worktrees, picker or agent handoff | `desktop/caelestia/openvide/AGENTS.md` |
| Update shared Lazygit (terminal + Openvide) | `desktop/caelestia/nix/lazygit.nix` (version/source) + `desktop/caelestia/openvide/nix/patches/lazygit-context.patch` |
| Edit Caelestia Shell config | `home-manager/configs/caelestia/shell.json` + `shell-tokens.json` |
| Edit icon theme | `home-manager/home.nix` (`gtk.iconTheme` + Caelestia service environment) |
| Edit opencode Neovim plugin | `home-manager/configs/opencode/plugins/nvim.ts` |
| Edit bar (waybar) | `home-manager/configs/waybar/config` + `style.css` |
| Edit widgets (eww) | `home-manager/configs/eww/eww.yuck` + `eww.scss` |
| Edit Git config/hooks | `home-manager/configs/git/` |
| Edit muk gh-dash/Claude workspace set | `home-manager/configs/hyprland/scripts/gh-dash-set.sh` + `home-manager/configs/hyprland/hosts/muk.lua`; checks in the gh-dash README |
| Edit gh-dash (muk only) | `home-manager/configs/gh-dash/config.yml`, installed by `home-manager/hosts/muk.nix` |
| Edit update/merge scripts | `home-manager/scripts/<name>.nix` |
| Edit MCP servers | `home-manager/configs/mcphub/servers.json` |
| Edit NixOS services | `nixos/configuration.nix` (systemd, networking, etc.) |
| New HM module | Create `home-manager/modules/<name>.nix`, import in `home.nix` |

## Targeted documentation

Read the relevant notes before changing these areas. Paths in those notes are relative to the
Bonsly root unless stated otherwise.

- [Desktop](docs/desktop.md): Hyprland layout, shortcuts, Firefox, fonts and shared Lazygit.
- [gardevoir](docs/gardevoir.md): boot/ESP constraints, storage, locking, games, portal and controller.
- [Agent tools](docs/agent-tools.md): launchers, skills, RTK, mutable settings and Claude permissions.
- [gh-dash](home-manager/configs/gh-dash/README.md): shortcuts, repository paths and checks.
- [Neovim](home-manager/configs/nvim/README.md): Unified.nvim configuration and Openvide startup.
- [Initial migration](docs/migration.md): installations predating host-specific outputs.
- [Openvide instructions](desktop/caelestia/openvide/AGENTS.md): sets, worktrees and agent delivery.

## Build and activation

```bash
update -h       # Home Manager switch
update -s       # NixOS switch (sudo)
update -r       # Hyprland reload only
update -hsr     # All three
```

`update -h` and `update -s` resolve their flakes from cwd or `BONSLY_FLAKE` (repo root or the
corresponding flake directory); Home Manager also falls back to `~/.config/home-manager`.
Outputs are NixOS `muk` / `gardevoir` and Home Manager `monzey@muk` / `monzey@gardevoir`.
Selection uses hostname unless `BONSLY_HOST` overrides it; unknown hosts fail before switching.
Identify the actual machine before selecting a host output; see the migration notes for an old hostname.

## Working conventions

- Agents started by opening an Openvide set (`OPENVIDE_SET_AGENT=1`) work in that set's checkout. The launcher hides the shared Openvide workflow skill for those sessions.
- For other sessions, before repository coding tasks or worktree creation, use the shared `openvide` skill: inspect `git worktree list`, reuse a suitable task checkout, otherwise create through Openvide. On continuation, keep the selected task worktree and check its set: open it through Openvide if absent, otherwise reuse or focus it without duplicating windows or agents. Skill source: `home-manager/configs/skills/openvide/SKILL.md`; distribution: `home-manager/modules/local-skills/default.nix`.
- Spec Kit uses `.agents/skills/speckit-*/` and `specs/`. Commit shared tooling, manifests,
  configuration and feature artifacts; respect `.specify/.gitignore` for local state.
- `home-manager/` and `nixos/` are independent flakes; rebuild only the affected configuration.
- Home Manager's `shell` input is `path:../desktop/caelestia` (Nix >= 2.26). Build shell edits with
  `update -h`; no separate Shell push or lock revision bump is needed. Add new files to Git before building.
- Caelestia is a full-history subtree. From a clean Bonsly root, merge upstream with
  `git subtree pull --prefix=desktop/caelestia https://github.com/caelestia-dots/shell.git main`;
  review conflicts/dependencies and build Home Manager afterward. Keep the license and subtree history.
- Shell dependencies are pinned in `home-manager/flake.lock`; the subtree lock is for standalone
  development. Update lockfiles with Nix commands, not by hand; avoid unrelated input updates.
- `configs/` files are linked through Home Manager (`xdg.configFile` / `home.file`). Edit their
  repository sources, not read-only runtime files such as Caelestia's `shell.json` / `shell-tokens.json`.
- Scripts use `pkgs.writeShellScriptBin` in `home-manager/scripts/`, exported through `home.nix`.
- Git uses `~/.config/git/hooks`; `commit-msg` removes all `Co-authored-by` trailers.

## Tool safeguards

- Codex's native npm installation lives in `~/.codex-npm`. Do not wrap its static musl binary in
  `buildFHSEnv`/Bubblewrap: desktop-inherited capabilities prevent launch.
- `~/.codex/AGENTS.md` is generated and read-only. Edit `home-manager/configs/codex/`;
  a custom `CODEX_HOME` needs separate wiring. Codex settings remain in `~/.codex/config.toml` outside Bonsly.
- Keep the single native Claude installation at the upstream-managed `~/.local/bin/claude` symlink.
  Do not replace it with a Home Manager file or reinstall nixpkgs `claude-code`. Preserve unrelated
  mutable Claude settings when changing activation merges.
- Copilot's npm prefix is separate from `~/.copilot`; do not export it as `COPILOT_HOME`.
- Firefox uses profile `default`. Keep remote commands enabled in Hyprland autostart (no
  `--no-remote`) and use the same profile for desktop URL handlers.
- Lazygit is shared by Home Manager and Openvide through `desktop/caelestia/nix/lazygit.nix`.
  Update its version/source hash and check the Openvide patch; no flake input update is required.

## Generated and unrelated files

- Do not manually edit `nixos/hosts/*/hardware-configuration.nix` (generated hardware configuration).
- Leave `animate/`, `preview.png`, `wall.png`, `recdsk` and binary cursor assets in
  `home-manager/configs/cursor/` alone unless the task concerns them.
