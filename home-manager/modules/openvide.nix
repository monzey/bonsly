{ config, pkgs, ... }:

let
  updateScript = pkgs.writeShellScriptBin "openvide" ''
    #!/bin/bash
    neovide -- --cmd "cd $(cd ~ && find . -maxdepth 2 -type d | dmenu)"
  '';
in
{
  home.packages = [ updateScript ];
}
