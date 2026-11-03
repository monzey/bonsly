{ pkgs, ... }:

{
  imports = [ ../home.nix ];
  bonsly.host = "gardevoir";
  home.packages = [ pkgs.steam pkgs.prismlauncher ];
}
