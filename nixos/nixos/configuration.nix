{ config, pkgs, ... }:

{
  imports = [ 
    /etc/nixos/hardware-configuration.nix
  ];

  system.stateVersion = "24.05";  # Version de NixOS à ajuster selon votre version

  # Configurations basiques du système
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "muk";
  networking.wireless.enable = true;
  networking.networkmanager.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LS_IDENTIFICATION = "fr_FR.UTF-8";
    LS_MEASUREMENT = "fr_FR.UTF-8";
    LS_MONETARY = "fr_FR.UTF-8";
    LS_NAME = "fr_FR.UTF-8";
    LS_NUMERIC = "fr_FR.UTF-8";
    LS_PAPER = "fr_FR.UTF-8";
    LS_TELEPHONE = "fr_FR.UTF-8";
    LS_TIME = "fr_FR.UTF-8";
  } 

  console.keyMap = "fr";

  user.users.monzey = {
    isNormalUser = true;
    description = "monzey";
    extraGroups = [ "wheel" "networkmanager" ];
  }

  services.dbus.enable = true;   # Nécessaire pour le fonctionnement de nombreux composants sous Wayland
  services.udev.packages = [ pkgs.libinput ];  # Nécessaire pour les périphériques d'entrée sous Wayland

  boot.kernelModules = [ "kvm-intel" ];  # Pour Intel, remplacez par "kvm-amd" si vous avez un processeur AMD

  nixpkgs.config.allowUnfree = true;

  programs.hyprland.enable = true; # enable Hyprland

  # Optional, hint Electron apps to use Wayland:
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Installation de logiciels essentiels
  environment.systemPackages = with pkgs; [
    # neovide      
    # mako         
    kitty
    # waybar       
  ];
}
