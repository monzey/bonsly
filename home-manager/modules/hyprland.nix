{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    wayland
    wayland-protocols
    wlroots
    xwayland
    hyprpaper
    hyprshot
  ];

  # Configuration Hyprland
  home.file.".config/hypr" = { source = ../configs/hyprland; recursive = true; };
}
