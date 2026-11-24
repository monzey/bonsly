# Openvide

Project/worktree selection, Hyprland development sets, Git and terminal drawers,
and native Codex/Claude task handoff live here. Read [AGENTS.md](AGENTS.md) before editing.

## Source layout

- `ui/`: the QML picker and its project-selection service.
- `scripts/`: set/worktree orchestration and agent selection.
- `codex/`: both Rust agent bridges, shared process validation and their tests.
- `profiles/`: Openvide's Neovim startup hook and Lazygit overlay.
- `tests/`: editor and runtime-layout checks.
- `nix/`: agent bridge/Lazygit builds and the Openvide-only Lazygit patch.

`../modules/openvide` is a source symlink to `ui/`, preserving the
`qs.modules.openvide` namespace during checkout development. CMake installs real
QML files at `modules/openvide/`; scripts and profiles are installed under
`openvide/`, with Nix-provided executables in `openvide/bin/`. Rust sources,
tests and documentation are not installed with the runtime resources.

Hyprland host settings, shared Neovim configuration and the agent skill remain
in Bonsly's Home Manager configuration. The shared Unified.nvim package and patch
remain in Caelestia's main Nix configuration.

## Native Codex handoff

Openvide's `scripts/openvide.sh --send-task <checkout-relative-to-HOME> [task-file|-]`
queues a task in a Codex terminal launched by the updated Openvide. Task text is
read from the file or stdin. The Rust executable in `codex/` launches a private native
`codex app-server` for each terminal and attaches the TUI with `codex --remote`.
The socket, checkout and process identities are recorded under the Openvide cache.
Sending validates the terminal and server, requires exactly one loaded root thread
in that checkout (excluding subagents), then calls `codex queue --remote` with its
UUID. Success means queued, not task completion. The server closes with the TUI.
Nix builds and installs it as `openvide/bin/openvide-codex`; Python is not required.
Other unsupported agents and older unbound terminals have no automatic delivery fallback.
After `/new` or `/resume`, delivery stops if multiple root sessions remain loaded
or the session has changed directories. Run tests from the Bonsly root:

```sh
cargo test --locked --manifest-path desktop/caelestia/openvide/codex/Cargo.toml
bash desktop/caelestia/openvide/tests/layout.sh
```

To check an installed package instead of the checkout, pass
`<package>/share/caelestia-shell` to `tests/layout.sh`. See [AGENTS.md](AGENTS.md)
for the headless editor regression test and the Home Manager build command.

## Claude channel handoff

The same `--send-task <checkout-relative-to-HOME> [task-file|-]` command routes to
Claude when that set's terminal was launched with `openvide-claude`. The launcher
keeps the ordinary Claude TUI and native installation, adding a session-only MCP
server named `openvide`. It uses Anthropic's experimental channels API with
`--dangerously-load-development-channels server:openvide`; accept the confirmation
in the terminal before sending. Existing terminals need to be reopened through
the updated launcher. Existing MCP servers and tool permissions remain in effect.
Channels require supported Anthropic authentication and may be blocked by an
organization policy. See the [official channel reference](https://code.claude.com/docs/en/channels-reference).

The bridge records the Claude and channel process identities and checkout under
`$XDG_CACHE_HOME/caelestia/openvide/claude`. It validates the terminal ancestry and
live checkout before delivering through a private local Unix socket. It never
simulates keystrokes, starts another model session or interrupts the current turn.
Task text is UTF-8 data (up to 1 MiB), passed unchanged to a channel notification.
Closing the terminal removes its binding and private runtime directory.

Claude is instructed to call `acknowledge_task` before doing the work. The command
waits up to 30 seconds for that receipt: JSON `status: "received"` confirms model
receipt, whereas `status: "forwarded", acknowledged: false` confirms only writing
to the MCP transport. A busy Claude may acknowledge later; an unapproved or
policy-blocked channel may silently discard the notification. An expired receipt
does not cancel the queued task. Never resend automatically after an unacknowledged
receipt or timeout. Neither receipt means task completion; responses stay in the
Claude terminal. No permissions are approved by this bridge.

## Development sets and tools

Openvide asks for the coding agent after selecting a project or a worktree
branch, before creating the worktree or opening any project windows. Escape
returns to the previous selection without launching anything. The selected
agent starts with the set; switching to an existing set keeps its windows.
The internal helpers accept `--open-project <project> <agent>` and
`--create-worktree <repo> <branch> <worktree-name> <agent>`.

With one or two screens, the initial tiled pair shares the code workspace:
the editor sits on the left with 65% of the width, and the agent on the
right with 35%. Additional user windows are left alone. With three or more
screens, the agent uses its separate workspace.

Bind `caelestia-ipc openvide terminal` to toggle a Kitty command terminal
for the current project (`Super + X` in bonsly). Each set has a persistent
terminal drawer, starting in its repository or worktree, on any screen
layout. Hiding the drawer keeps the shell and running commands alive;
closing the terminal allows the shortcut to recreate it. The terminal is
created on first use, after the set has been opened and its agent selected.
Alternating the Git and terminal shortcuts shows the existing window for
the set underneath the drawer. Pressing the visible tool's shortcut hides
it and returns to the code or agent window, never to the other drawer.
Both shortcuts are serialized against fresh Hyprland state to avoid
duplicate launches and focus loops during rapid keypresses.
In bonsly's Hyprland configuration, project tool windows cannot inhibit
compositor shortcuts. Changing workspace hides the current special
workspace, so its terminal does not cover the destination.

Bind `caelestia-ipc openvide git` in Hyprland to toggle Git for the current
development project (`Super + G` in bonsly). With one or two screens, it
shows or hides the project's lazygit drawer. With three screens, it toggles
between the dedicated Git workspace and the previous window. If that window
was closed, it returns to the previous project workspace instead.
Lazygit shows the active worktree, remotes and commit graph in full-width
panels, with most space given to the focused panel. `2`, `3` and `4` jump
to worktrees, remotes and commits; pressing a panel's number again cycles
its tabs. Worktrees show their branch and full path, with `*` marking the
current worktree; remotes show their URLs. The graph includes all branches.
Neovim remains the diff viewer.
The Openvide profile in `profiles/lazygit.yml` overlays the user's
Lazygit configuration, retaining its theme and keybindings. The Nix package
supplies Lazygit 0.66.3 with Worktrees and Remotes selected by default in this
profile; ordinary Lazygit sessions keep their usual startup.
Each project set has its own lazygit process rooted in its repository or
worktree. Openvide remembers this association in
`$XDG_CACHE_HOME/caelestia/openvide` (default `~/.cache/caelestia/openvide`).
If Git has been closed, the shortcut reopens it for that set. Existing sets
can recover their repository from the working directories of their windows.

Unified is configured in the shared Home Manager Neovim configuration.
`<leader>gu` opens its diff view from any Neovim session.
Openvide loads `profiles/neovim.lua` as a startup hook and opens
unified.nvim against `HEAD`. Diffs decorate real file buffers, preserving
normal editing and the user's language-server configuration. The dashboard is replaced on opening. The changed-file
panel stays visible after selecting a file, and selection focuses the code window.
`<leader>b` toggles the panel; `Enter` or `l` selects a file. `]h` / `[h`
navigate changed hunks. Long lines wrap.

Clean repositories keep the panel open until the first change appears.
Openvide checks Git status and external file changes every second while the
unified view is active. The first changed file opens automatically. Unsaved
edits use Neovim's normal conflict handling and are never forcibly reloaded.
`<leader>gD` clears the unified view and opens Diffview for side-by-side review;
`:DiffviewClose` closes it, and `:Unified HEAD` resumes the unified view.
`:Unified reset` stops the view and its polling work.

The Nix package supplies pinned unified.nvim, Diffview and plenary.nvim,
linked by Home Manager into `~/.local/share/nvim/nix-plugins`.
The unified.nvim patch disables external diff drivers for machine-readable
patches, so a global `diff.external = difft` does not break the view.
Neovim launched outside Openvide keeps its usual startup.
