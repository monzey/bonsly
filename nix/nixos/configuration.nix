{ config, pkgs, ... }:

{
  # Paramètres de base de NixOS
  imports = [ 
    ./hardware-configuration.nix
  ];

  # Nom de la machine
  system.stateVersion = "23.05";  # Version de NixOS à ajuster selon votre version

  # Configurations basiques du système
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Configuration Wayland et Hyprland
  services.wayland = {
    enable = true;

    # Hyprland - Compositeur Wayland
    compositor = {
      hyprland.enable = true;
      hyprland.configFile = "/etc/hypr/hyprland.conf";  # Vous pouvez personnaliser le fichier de configuration
    };
  };

  # Gestionnaire de login pour Wayland (Greetd)
  services.greetd = {
    enable = true;
    defaultSession = "Hyprland";
  };

  # Notifications avec Mako
  services.mako = {
    enable = true;
  };

  # Installation de logiciels essentiels
  environment.systemPackages = with pkgs; [
    neovide      
    mako         
    hyprland     
    kitty
    waybar       
    networkmanager  
  ];

  # Configurations réseau
  networking.networkmanager.enable = true;

  # Autres services nécessaires
  services.dbus.enable = true;   # Nécessaire pour le fonctionnement de nombreux composants sous Wayland
  services.udev.packages = [ pkgs.libinput ];  # Nécessaire pour les périphériques d'entrée sous Wayland

  # Gestion du son
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Configuration du noyau
  boot.kernelModules = [ "kvm-intel" ];  # Pour Intel, remplacez par "kvm-amd" si vous avez un processeur AMD
}
