{ config, pkgs, ... }:

let
  updateScript = pkgs.writeShellScriptBin "rustdev" ''
    #!/bin/sh
    set -e

    nix develop $HOME/bonsly/devShells/rust
  '';
in
{
  home.packages = [ updateScript ];
}
