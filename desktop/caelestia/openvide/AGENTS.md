# Openvide

These instructions supplement Bonsly's root AGENTS.md. Keep this file current
when entry points, paths or behaviour change. This directory belongs to the
Caelestia full-history subtree; preserve its upstream license and history.

## Entry points

| Task | Start here |
|------|------------|
| Select projects, branches, worktrees or agents in the picker | `ui/services/Projects.qml` |
| Change picker appearance | `ui/Wrapper.qml`, `Content.qml`, `ContentList.qml`, `items/` |
| Create/reuse sets, place windows, toggle drawers | `scripts/openvide.sh` |
| List/check/launch supported agents | `scripts/agent-menu.sh` |
| Deliver tasks to an existing Codex session | `codex/src/main.rs`, `codex/tests/handoff.rs` |
| Deliver tasks to an existing Claude session | `codex/src/bin/openvide-claude.rs`, `codex/tests/claude.rs` |
| Validate shared agent process identities | `codex/src/session.rs` |
| Open the editor's diff view on startup | `profiles/neovim.lua`, `tests/neovim.lua` |
| Change the Git overview | `profiles/lazygit.yml`, `nix/patches/lazygit-context.patch` |
| Build agent bridges or patched Lazygit | `nix/default.nix` |

The shell integration points remain outside this folder: `../services/Hypr.qml`
for tool dispatch, `../modules/drawers/Panels.qml` for the picker, and
`../CMakeLists.txt` / `../nix/default.nix` for installation. Machine keybindings
stay in Bonsly's `home-manager/configs/hyprland/`. The shared agent workflow is
`home-manager/configs/skills/openvide/SKILL.md` at the Bonsly root.

## Paths and packaging

- Edit QML under `ui/`. `../modules/openvide` is only a source symlink that keeps
  `qs.modules.openvide` imports working in a checkout. Do not create a second copy.
- CMake installs real QML files under `<shellDir>/modules/openvide/` and scripts
  and profiles under `<shellDir>/openvide/{scripts,profiles}/`.
- Nix links the Codex, Claude and Lazygit executables under `<shellDir>/openvide/bin/`.
  Scripts resolve resources relative to their parent Openvide directory.
- The Caelestia package exposes `bin/openvide` as a wrapper for the installed
  `<shellDir>/openvide/scripts/openvide.sh`. Use `openvide --list-projects`
  to check the command from the Home Manager profile or the built package.
- The shell's Nix source fileset includes `ui/`, `scripts/` and `profiles/`.
  The Rust package has a separate fileset and Cargo lockfile; do not install its
  sources, tests or documentation as shell resources.
- Ordinary Neovim's Unified.nvim configuration and plugin patch are shared with
  Home Manager and remain outside this feature. The `assets/nvim-plugins`
  installation path is also shared and must remain stable.

## Behaviour to preserve

- The workspace picker lists live Steam game workspaces named `steam-<id>` whenever opened. Its IPC entry point is `openvide switchWorkspace` in `../modules/Shortcuts.qml`.
- Agents launched with a new set inherit `OPENVIDE_SET_AGENT=1` and a private mount that hides the Home Manager Openvide skill. This also covers the private Codex app-server.
- Select and validate the coding agent before creating worktrees or windows.
  Reopening a set reuses its windows and does not change its agent.
- With one or two monitors, the initial editor/agent pair is 65%/35%, agent on
  the right. Do not rearrange additional windows. Three or more monitors use
  separate workspaces; keep the existing host monitor mapping.
- Git and terminal shortcuts are serialized, reuse windows by class and restore
  only code/agent focus. Resolve the set from the underlying workspace; one
  drawer is visible at a time. Hiding a terminal preserves its running shell.
- Preserve existing worktrees and uncommitted changes. Project/worktree arguments
  passed to the shell helper are relative to HOME; set IDs are not filesystem paths.
- Codex handoff runs a private native app-server per terminal. Validate process
  identities, terminal ancestry and checkout, then require exactly one loaded
  root thread, excluding subagents. Send with `codex queue --remote` and its exact
  UUID. Never guess a session, simulate keystrokes, interrupt an active turn or
  queue a task back to the same session. Unsupported/old unbound terminals fail
  explicitly. Wait briefly when no root session has loaded and surface pending
  terminal prompts if it remains unavailable. A receipt confirms queueing, not
  completion; uncertain sends must not be retried automatically. Closing the
  terminal also stops its private server.
- Claude handoff uses `openvide-claude` and a private per-terminal MCP stdio channel
  (`server:openvide`), reached through a Unix socket in a mode-0700 runtime directory.
  The launcher adds `--mcp-config` and `--dangerously-load-development-channels`
  for this server only; keep tool permissions and existing MCP configuration intact.
  Users must accept Claude's experimental-channel confirmation. Organization
  channel policy still applies. Validate live process identities, checkout and
  terminal ancestry before sending; reject self-delivery and unbound terminals.
  `received` means the model called `acknowledge_task`; `forwarded` after 30 seconds
  means written to MCP without model acknowledgement, possibly busy or blocked.
  Neither means completed. Never retry an uncertain or unacknowledged send
  automatically. A late acknowledgement may expire while the task remains queued.

## Verification

From the Bonsly root, with the corresponding tools available:

```sh
bash -n desktop/caelestia/openvide/scripts/openvide.sh
bash -n desktop/caelestia/openvide/scripts/agent-menu.sh
cargo test --locked --manifest-path desktop/caelestia/openvide/codex/Cargo.toml
bash desktop/caelestia/openvide/tests/layout.sh
# OPENVIDE_SHELL_PACKAGE is the built shell's store path.
OPENVIDE_TEST_PLUGINS="$OPENVIDE_SHELL_PACKAGE/share/caelestia-shell/assets/nvim-plugins" \
  XDG_CACHE_HOME=/tmp/openvide-test-cache NVIM_LOG_FILE=/tmp/openvide-test.log \
  nvim --headless -u NONE -i NONE -c 'luafile desktop/caelestia/openvide/tests/neovim.lua'
nix build --no-link ./home-manager#homeConfigurations.'monzey@gardevoir'.activationPackage
```

Use the appropriate Home Manager host output. Include new files in Git before
flake builds. Verify the installed QML/scripts/profiles/binaries after packaging
changes; source layout alone does not prove installed paths. Build and activation
are separate: `update -h` applies the configuration and may restart the shell.
Live focus/layout checks require an accessible Hyprland session; report when they
cannot be performed.
