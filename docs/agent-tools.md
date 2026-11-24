# Agent tool integrations

Paths below are relative to the Bonsly root. Edit the declared modules and source configuration;
generated files and mutable upstream installations have different ownership.

## Codex

Codex CLI uses a native npm launcher in `home-manager/modules/codex/default.nix`, with Node and
command dependencies on PATH. Its Linux binary is static musl; do not wrap it in
`buildFHSEnv`/Bubblewrap, which rejects capabilities inherited from desktop launches. The mutable
npm installation remains in `~/.codex-npm`.

`home-manager/modules/codex/default.nix` assembles common guidance and only the selected host's
context into `~/.codex/AGENTS.md`. Edit its sources in `home-manager/configs/codex/`; the generated
file is read-only. This is agent/Codex guidance, not an automatic replacement for ordinary ChatGPT
chat custom instructions. A custom `CODEX_HOME` needs separate wiring.

## Openvide delivery

Home Manager exposes `openvide` through Caelestia's `with-cli` package. Use `openvide
--list-projects` to list projects. `openvide --send-task` supports bound Codex and Claude terminals;
Claude uses a private experimental MCP channel with terminal confirmation. See
`desktop/caelestia/openvide/AGENTS.md` for receipt semantics.

## Third-party skills

Third-party agent skills are pinned with `fetchFromGitHub` (Caveman uses `sparseCheckout` of the
skill dirs) and linked with `home.file`. Same store path into `~/.agents/skills`, `~/.grok/skills`
and `~/.claude/skills`. Parents stay unmanaged. Read-only at runtime. Bump `rev` + `hash` in the
module to update. Ponytail's main skill is imported through shared `home.nix` for both hosts; its
plugin, hooks and companion skills are not installed.

## OpenCode

opencode runs in an FHS env (see `home-manager/modules/opencode/default.nix`)

## RTK and Copilot

Both hosts install RTK from the pinned unstable input via `home-manager/modules/rtk/`, imported by
the shared `home-manager/home.nix`. Its pinned binary generates Codex, OpenCode, Copilot CLI and
Antigravity integration files during the build; activation merges the Claude Code hook without
replacing existing settings. Grok has no RTK integration. Copilot's npm prefix is separate from its
standard `~/.copilot` configuration directory; do not export that prefix as `COPILOT_HOME`.

## Claude Code

Claude Code uses one native installation per host: Home Manager's `claude` launcher forwards to the
upstream-managed `~/.local/bin/claude` symlink, installing it from `https://claude.ai/install.sh`
with `latest` on first use if missing. Terminal, Openvide and URL handlers use that same
installation; do not replace the mutable native symlink with a Home Manager file or reinstall the
nixpkgs `claude-code` package. Native binaries use the shared NixOS `programs.nix-ld` support.
`claude update` updates the binary without rebuilding Home Manager; restart Claude sessions
afterward.

The shared Claude module merges the `latest` update channel and, on muk,
`home-manager/configs/claude/muk.json` into the mutable `~/.claude/settings.json` on Home Manager
activation: objects merge recursively, arrays are combined without duplicates, and declared scalar
values take precedence. Existing unrelated settings are preserved. muk pre-approves
`*.dashboard.rg-supervision.local` for WebFetch and sandbox networking, the `npx playwright` /
`playwright` command prefixes, and the exact command `ssh dev@localhost -p 8888`. Playwright command
permissions cover their arguments globally; they do not restrict Playwright to that domain or to
headless mode.
