# Monzey's dotfiles
![Alt text](./preview.png?raw=true "Title")

## From a fresh install of nixos

```bash
  git clone https://github.com/monzey/bonsly.git && cd bonsly
  chmod a+x setup
  ./setup
```

If you want to update your system, you just have to do 
```bash
  update -hsr
```

don't forget to add your private ssh key in `home-manager/configs/ssh/id_ed25519` and to run `update` right after

That's it !

## Caelestia desktop shell

The customised shell lives in `desktop/caelestia/`, imported with its complete
Git history using `git subtree`. Edit its QML, Openvide scripts and Nix package
there. Home Manager uses that local flake directly; there is no separate Shell
repository to publish or revision to pin after editing it.

```bash
home-manager switch --flake ./home-manager#monzey
```

Nix 2.26 or newer is required for the relative local flake input. New files
must be added to Git before building. Runtime settings remain in
`home-manager/configs/caelestia/`; Hyprland bindings remain in
`home-manager/configs/hyprland/`.

Upstream updates can be merged from the Bonsly root with a clean working tree:

```bash
git subtree pull --prefix=desktop/caelestia https://github.com/caelestia-dots/shell.git main
```

Resolve conflicts with the local customisations, review dependency changes,
then build Home Manager before activating. Updating upstream sources does not
automatically update the dependencies pinned in `home-manager/flake.lock`.
The imported upstream GitHub workflows stay inside the subtree and are not
active Bonsly workflows. The former standalone clone is no longer used by
Home Manager.
