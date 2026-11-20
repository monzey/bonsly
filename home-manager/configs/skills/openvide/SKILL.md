---
name: openvide
description: Use before starting any repository coding task (implementation, fix, refactor or task continuation), and whenever considering creating or switching a Git worktree. Inspect existing worktrees first, reuse the task's checkout or create one through Openvide, then open or focus its development set. Desktop actions require local shell access and Hyprland.
---

# Openvide

Before editing files for a repository task, select its worktree and Openvide set using this workflow, even if the user did not explicitly ask to open a set. Preserve the requested project, agent and task. Pure questions and read-only exploration do not require a new workspace. On task continuation, keep the selected worktree but check whether its Openvide set is currently open. If absent, open the set through Openvide; if present, reuse or focus it without duplicating windows or agents. Do not create another worktree merely because the set is closed.

## Select the task's worktree first

Resolve the repository from the request and current context, then inspect Git's registry before any creation:

```bash
git -C "$repo" rev-parse --show-toplevel
git -C "$repo" worktree list --porcelain -z
```

Use a NUL-aware parser for the registry. It includes the main checkout and linked worktrees, including those outside Openvide's usual directory. Openvide's visible sets are not a complete worktree inventory. Inspect candidate branches, `git -C "$candidate" status --short --branch`, recent commits and relevant task artifacts to determine whether a checkout belongs to this task. A similar directory name alone is insufficient.

Reuse an explicitly selected checkout or an existing worktree that clearly matches the task. Preserve its uncommitted work; unrelated changes or an agent already working on another task make it unsuitable for automatic reuse. Ask if multiple candidates remain plausible. Do not reset, stash, remove, prune, unlock or force-checkout worktrees to make room.

If no suitable checkout exists, create a dedicated worktree through Openvide rather than running `git worktree add` directly. Choose a descriptive branch and a simple unique worktree directory name (no slashes); check both branch ownership in the registry and destination existence. Respect an explicit instruction to work in the current checkout. If already inside the appropriate task worktree, continue there, then ensure its set is open as described below.

## Discover the local interface

Read the project's AGENTS.md. Find the installed Openvide helpers under `<shellDir>/openvide/scripts/` from the running Caelestia service/package, or use `desktop/caelestia/openvide/scripts/openvide.sh` and its adjacent `agent-menu.sh` in the local Bonsly checkout. Read `desktop/caelestia/openvide/AGENTS.md` when changing Openvide itself. Prefer the installed version for the active desktop. Inspect the actual helpers before using them; interfaces may differ between installations. Do not assume that a chat client has local shell access or inherits the desktop environment.

The current Bonsly helpers support these calls (`helper` and `agents` below are absolute paths to the discovered scripts):

```bash
bash "$helper" --list-projects
bash "$helper" --list-sets
bash "$agents" --list
bash "$helper" --open-project "$project_relative_to_home" "$agent"
bash "$helper" --switch-set "$set_id"
bash "$helper" --send-task "$project_relative_to_home" "$task_file"
```

Listings return JSON entries with `kind`, `value` and `label`. Use returned values, not display labels. Project arguments are relative to `$HOME`; validate the resolved directory and repository before opening. Agent values must come from `agent-menu.sh --list`; validate availability with `--check "$absolute_project_path" "$agent"` before creating a set. Use the user's selected agent or established preference; ask if neither supplies a choice.

## Open or reuse the set

Resolve the project from the request, current repository and listings. Ask only if multiple candidates remain plausible. Check existing sets independently of existing worktrees, including on task continuation. If the selected worktree has no open set, call `--open-project` with that worktree path and the selected agent to create its set. If its set is already open, reuse or focus it without creating another set or relaunching its agent. `--open-project` reuses and focuses an existing project set; it does not replace its agent. Inspect the registry under `${XDG_CACHE_HOME:-$HOME/.cache}/caelestia/openvide` and Hyprland clients when needed to disambiguate sets with the same basename. Do not reuse a set merely because its name matches a different repository.

Let Openvide handle monitor placement, workspace naming, editor and agent launch. Do not recreate its layout with independent window commands. Quote paths and arguments; never treat the user's task text as shell code.

For a new worktree, inspect the actual `--create-worktree` implementation first. The current signature is `--create-worktree "$repo_relative_to_home" "$branch" "$worktree_name" "$agent"`. Prefer the main checkout as its repository argument so placement remains predictable. It creates a sibling `<repo>.worktrees/<worktree_name>` directory (or reuses the parent container when called from an immediate child of a `.worktrees` directory).

An existing local branch is checked out as is; an existing `origin` branch gets a local tracking branch. Otherwise the new branch starts at local `origin/HEAD`, falling back to the current branch, then `main`. No fetch is performed. Check that this base matches the task; the helper has no explicit base argument. If it cannot express the required base, explain the limitation instead of silently changing the base or bypassing the Openvide workflow. After creation, verify the new entry with `git worktree list` and its branch before editing files. On failure, inspect the registry and destination before retrying; do not blindly create a second worktree.

## Hand off the task and verify

When routing a task from a general assistant to the agent in a set, synthesize the objective, relevant context, constraints and validation into a concise message. Preserve explicit user requirements. Write it to a temporary UTF-8 file and call `--send-task` with the selected checkout relative to HOME and the file path (or `-` to read stdin), then remove the temporary file. Task text is data, never shell code. If already executing inside the target set's Codex session, continue the task there instead of queueing it back to yourself or starting another agent.

Codex is currently the only native handoff implementation. Updated Openvide launches give each Codex terminal a private native app-server socket bound to its checkout and process identities. `--send-task` validates the terminal process ancestry and native server, requires exactly one loaded root thread (excluding subagents), verifies its working directory, then uses `codex queue --remote` with that exact thread UUID. It does not interrupt a running turn or start a second agent. A successful receipt means queued, not completed. Do not retry an uncertain or timed-out send automatically: it may have queued the message already.

The private server identifies the loaded session in that terminal. After `/new` or `/resume`, sending is allowed only when exactly one root session is loaded and its directory still matches; ambiguity or a changed directory must stop delivery. Old unbound terminals and unsupported agents must not receive guessed-session or simulated-keyboard fallbacks. If the binding is unavailable, report the failure and provide the task text for manual delivery; do not close an existing agent without authorization.

Verify the expected set and its actual windows through the listings and `hyprctl clients -j`. Report separately whether the set opened, which agent is present, and whether the task was delivered. An existing set may contain a different agent. If local execution, the desktop session or required permissions are unavailable, explain the specific missing capability and provide the exact next command without claiming execution.
