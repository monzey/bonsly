# AGENT.md — bonsly dotfiles

## Agent instructions
After any change to this repo: update this file if affected entry points, paths, or conventions have changed.

NixOS + Home Manager dotfiles repo. No app code, no DB, no tests, no package.json.
Two separate Nix flakes. One user: `monzey`, machine: `muk`.

## Repo map

```
nixos/                        ← NixOS system config (root-level, requires sudo)
  flake.nix                   ← system flake entry point
  configuration.nix           ← services, boot, users, hardware
  hardware-configuration.nix  ← do not edit manually

home-manager/                 ← user-level config (no sudo)
  flake.nix                   ← HM flake entry point
  home.nix                    ← aggregates all modules + packages
  modules/                    ← zsh, hyprland, rofi, AI CLI tools
  scripts/                    ← nix-wrapped shell scripts (update, merge, etc.)
  configs/                    ← per-tool dotfiles, symlinked into ~/.config/
    hyprland/                 ← WM config, keybinds, monitor layout, scripts
    nvim/                     ← LazyVim config (lua/config/, lua/plugins/)
    opencode/                 ← opencode.json, plugins/nvim.ts, skills/
    waybar/                   ← bar config + style.css
    eww/                      ← eww.yuck + eww.scss widgets
    kitty/                    ← terminal config
    zsh -> modules/zsh.nix
    git/                      ← gitconfig
    mcphub/                   ← MCP servers config (servers.json)

animate/                      ← rain animation PNGs + shell scripts (ignore unless asked)
```

## Entry points by task

| Task | Start here |
|------|-----------|
| Add/remove system package | `nixos/configuration.nix` |
| Add/remove user package | `home-manager/home.nix` (packages list) |
| Edit shell (zsh, aliases, env) | `home-manager/modules/zsh.nix` |
| Edit keybinds / WM behaviour | `home-manager/configs/hyprland/hyprland.conf` |
| Edit monitor layout | `home-manager/configs/hyprland/hyprland.conf` (monitor + workspace rules) |
| Edit Neovim plugin | `home-manager/configs/nvim/lua/plugins/<name>.lua` |
| Edit Neovim options/keymaps | `home-manager/configs/nvim/lua/config/` |
| Edit opencode config | `home-manager/configs/opencode/opencode.json` |
| Edit opencode Neovim plugin | `home-manager/configs/opencode/plugins/nvim.ts` |
| Edit opencode skills | `home-manager/configs/opencode/skills/` |
| Edit bar (waybar) | `home-manager/configs/waybar/config` + `style.css` |
| Edit widgets (eww) | `home-manager/configs/eww/eww.yuck` + `eww.scss` |
| Edit update/merge scripts | `home-manager/scripts/<name>.nix` |
| Edit MCP servers | `home-manager/configs/mcphub/servers.json` |
| Edit NixOS services | `nixos/configuration.nix` (systemd, networking, etc.) |
| New HM module | Create `home-manager/modules/<name>.nix`, import in `home.nix` |

## Build commands

```bash
update -h       # home-manager switch (user config)
update -s       # sudo nixos-rebuild switch (system config)
update -r       # hyprctl reload (WM only, instant)
update -hsr     # all three — standard full update
```

## Key conventions

- Nix flakes: `home-manager/` and `nixos/` are independent — changes to one don't require rebuilding the other
- `configs/` dirs are symlinked to `~/.config/<tool>/` via Home Manager `xdg.configFile` or `home.file`
- Scripts live as `.nix` files (wrapped with `pkgs.writeShellScriptBin`) in `home-manager/scripts/`, exported as packages in `home.nix`
- Pinned packages (e.g. lazygit v0.48.0) use `pkgs.unstable` or manual `fetchurl` overrides in `home.nix`
- opencode runs in an FHS env (see `home-manager/opencode-bin.nix`)

## Ignore

- `animate/` (rain animation assets, not config)
- `nixos/hardware-configuration.nix` (auto-generated)
- `home-manager/flake.lock`, `nixos/flake.lock` (lockfiles, update with `nix flake update`)
- `preview.png`, `wall.png`, `recdsk` (assets/scripts unrelated to config)
- `home-manager/configs/cursor/` (binary cursor theme assets)
- `home-manager/configs/nvim/lua/plugins/dart.lua`, `php.lua` (language plugins, rarely touched)
