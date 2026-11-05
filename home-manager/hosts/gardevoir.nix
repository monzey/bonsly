{ pkgs, ... }:

{
  imports = [ ../home.nix ];
  bonsly.host = "gardevoir";
  dconf.settings."org/gnome/desktop/interface".enable-animations = true;
  home.packages = [ pkgs.steam pkgs.prismlauncher ];
}
