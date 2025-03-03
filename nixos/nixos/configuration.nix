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
  #networking.wireless.enable = true;
  networking.networkmanager.enable = true;
  networking.extraHosts =
    ''
    127.0.0.1 api.rg-supervision.local
    127.0.0.1 dashboard.rg-supervision.local
    127.0.0.1 zaza.rg-supervision.local
    '';

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

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
  }; 

  console.keyMap = "fr";

  users.users.monzey = {
    isNormalUser = true;
    description = "monzey";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  services.dbus.enable = true;   # Nécessaire pour le fonctionnement de nombreux composants sous Wayland
  services.udev.packages = [ pkgs.libinput ];  # Nécessaire pour les périphériques d'entrée sous Wayland
  services.greetd.enable = true;

  services.openvpn.servers = {
    dev = { 
      config = "config /root/openvpn/mbertrand.ovpn"; 
      updateResolvConf = true;
    };
  };

  services.kanata.enable = true;
  services.kanata.keyboards.default.config = ''
    (defsrc
      rshift
      caps)
    
    (deflayermap (default-layer)
      rshift esc
      caps lctl)
  '';

  boot.kernelModules = [ "kvm-intel" ];  # Pour Intel, remplacez par "kvm-amd" si vous avez un processeur AMD

  nixpkgs.config.allowUnfree = true;

  fonts.packages = [
    pkgs.fira-code-nerdfont
  ];

  programs.regreet.enable = true; 
  programs.regreet.settings = /home/monzey/.config/regreet/regreet.toml; 
  programs.regreet.cageArgs = ["-s" "-m" "last"];
  programs.hyprland.enable = true; 
  programs.hyprlock.enable = true; 
  programs.zsh.enable = true; 
  programs.steam.enable = true;

  virtualisation.docker.enable = true;

  # Optional, hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.EDITOR = "neovide";
  environment.sessionVariables.XKB_DEFAULT_LAYOUT = "fr";

  # Installation de logiciels essentiels
  environment.systemPackages = with pkgs; [
    git
    stow
    mako         
    wofi
    dunst
    brightnessctl
    wl-clipboard
    waybar       
    greetd.regreet
    kitty
    chromium
    firefox
    neovide      
    neovim
    lazygit
    gnumake
    fzf
    delta
    fira-code-nerdfont
    ranger
    antigen
    eza
    hyprpaper
    ripgrep
    slack
    bat
    btop
    hyprshot
    xdg-desktop-portal-hyprland
    pipewire
    wireplumber
    discord
    nodejs_20
    neofetch
    wine-wayland
    unzip
    grim
    slurp
    xplr
    oxker
    gccgo
    go_1_21
    mkcert
    steamcmd
    steam-tui
    superfile
    openconnect
    globalprotect-openconnect
    vscode
    cassandra
    figma-linux
  ];
}
