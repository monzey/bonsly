{ config, pkgs, inputs, ... }:

{
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
  
  nix.settings.experimental-features = ["nix-command" "flakes"];

  system.stateVersion = "24.05";

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
    127.0.0.1 local.staging.rg.gg
    '';

  console.keyMap = "fr";

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;

  time.timeZone = "Europe/Paris";

  users.users.monzey = {
    isNormalUser = true;
    description = "monzey";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
  };

# @TODO handle this properly
  programs.zsh.enable = true;

  services.dbus.enable = true;
  services.udev.packages = [ pkgs.libinput ];  

# @TODO handle this properly
  services.kanata.enable = true;
  services.kanata.keyboards.default.config = ''
    (defsrc
      rshift
      caps)
    
    (deflayermap (default-layer)
      rshift esc
      caps lctl)
  '';

  services.openvpn.servers = {
    dev = { 
      config = "config /root/openvpn/mbertrand.ovpn"; 
      updateResolvConf = true;
    };
  };

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.hyprland}/bin/hyprland";
        user = "monzey";
      };
      default_session = initial_session;
    };
  };

  boot.kernelModules = [ "kvm-intel" ];  # Pour Intel, remplacez par "kvm-amd" si vous avez un processeur AMD

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    EDITOR = "neovide";
    XKB_DEFAULT_LAYOUT = "fr";
  };
}
