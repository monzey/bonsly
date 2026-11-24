# gh-dash

Configuration: `config.yml`. Paths in these notes are relative to the Bonsly root.

## Host and sections

gh-dash's custom configuration is installed only on muk through `home-manager/hosts/muk.nix`; it
includes the existing PR sections and a KB stories section filtered by `repo:rgsystemes/kb
assignee:@me is:open`. gardevoir does not receive this configuration.

## PR diffs

gh-dash's PR shortcut `d` fetches the selected PR refs and opens Neovide with `DiffviewOpen
<base>...<head>`, without checking out a branch. Its Home Manager-managed config maps `monzey/*` to
`/home/monzey/monzey/*` and `rgsystemes/*` to `/home/monzey/rg/*`; the `monzey/rgsupv-dashboard`
fork also uses `/home/monzey/rg/rgsupv-dashboard`. Paths must be absolute because gh-dash passes
them literally to the quoted `cd` command. Repositories must already exist locally and use GitHub
SSH access.

## PRs mentioning an issue

In gh-dash's Issues view, `Alt+p` lists PRs mentioning the selected issue across repositories, with
their current open/draft/merged/closed state; `q` returns from the pager. The command in
`home-manager/configs/gh-dash/config.yml` paginates GitHub timeline cross-references, deduplicates
PR URLs and reads fresh PR metadata. Results depend on the authenticated `gh` account's access and
include historical mentions, even if subsequently removed; they do not represent a completeness
check for a story.

## Workspace integration

The gh-dash/Claude desktop set is implemented in
`home-manager/configs/hyprland/scripts/gh-dash-set.sh` and
`home-manager/configs/hyprland/hosts/muk.lua`. Its layout is documented in
[the desktop notes](../../../docs/desktop.md).

From the Bonsly root, check changes with:

```bash
python3 home-manager/configs/gh-dash/test-issue-prs.py
python3 home-manager/configs/hyprland/scripts/test-gh-dash-set.py
```
