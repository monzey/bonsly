{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    wayland
    wayland-protocols
    wlroots
    xwayland
    hyprpaper
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    hyprshot
    pipewire
    wireplumber
  ];

  # Configuration Hyprland
  home.file.".config/hypr" = { source = ../configs/hyprland; recursive = true; };
}
