{ config, pkgs, ... }:

let
  launchScript = pkgs.writeShellScriptBin "launch" ''
    #!/bin/bash
    $HOME/.config/rofi/scripts/launcher_t1
  '';
  dmenuScript = pkgs.writeShellScriptBin "dmenu" ''
    #!/bin/bash
    $HOME/.config/rofi/scripts/dmenu
  '';
in
{
  home.packages = [ 
    launchScript 
    dmenuScript 
  ];
}
