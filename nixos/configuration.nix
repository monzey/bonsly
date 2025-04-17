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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "kvm-intel" ];

  networking.hostName = "muk";
  networking.networkmanager.enable = true;
  networking.extraHosts = 
    ''
      127.0.0.1 api.rg-supervision.local
      127.0.0.1 dashboard.rg-supervision.local
      127.0.0.1 zaza.rg-supervision.local
      127.0.0.1 local.staging.rg.gg
    ''
  ;

  console.keyMap = "fr";

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;

  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "monzey" ];

  time.timeZone = "Europe/Paris";

  users.users.monzey = {
    isNormalUser = true;
    description = "monzey";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
  };

  virtualisation.docker.enable = true;

  services.openvpn.servers = {
    dev = {
      config = "config /root/openvpn/mbertrand.ovpn";
      updateResolvConf = true;
    };
  };

  services.blueman.enable = true;
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

  # @TODO handle this properly
  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    EDITOR = "neovide";
    XKB_DEFAULT_LAYOUT = "fr";
  };
}
