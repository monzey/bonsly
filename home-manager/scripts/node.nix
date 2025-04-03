{ config, pkgs, ... }:

let
  updateScript = pkgs.writeShellScriptBin "node22" ''
    #!/bin/sh
    set -e

    nix develop $HOME/bonsly/devShells/node#node22
  '';
in
{
  home.packages = [ updateScript ];
}
