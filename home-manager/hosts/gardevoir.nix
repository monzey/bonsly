{ pkgs, ... }:

{
  imports = [ ../home.nix ../modules/rtk ];
  bonsly.host = "gardevoir";
  dconf.settings."org/gnome/desktop/interface".enable-animations = true;
  home.packages = [ pkgs.steam pkgs.prismlauncher ];
}
