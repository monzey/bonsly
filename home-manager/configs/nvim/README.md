# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Bonsly Unified.nvim integration

Unified.nvim is configured for ordinary Neovim in
`home-manager/configs/nvim/lua/plugins/unified.lua` and `home-manager/configs/nvim/lua/config/unified.lua`; `<leader>gu` opens
diffs against HEAD. Home Manager links the shell's pinned, patched plugins into
`~/.local/share/nvim/nix-plugins`. `desktop/caelestia/openvide/profiles/neovim.lua` only triggers
the diff view on set startup. The shared configuration polls external edits, uses editable buffers,
replaces the dashboard on opening and keeps the panel visible on selection, and provides
`<leader>b`, `]h` / `[h` and `<leader>gD`. The patch in
`desktop/caelestia/nix/patches/unified-no-external-diff.patch` bypasses external diff drivers.
Ordinary startup leaves the diff view closed.

Paths above are relative to the Bonsly root.
