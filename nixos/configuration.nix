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
  hardware.pulseaudio.enable = false;
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

  services.intune.enable = true;

  # @TODO handle this properly
  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    EDITOR = "neovide";
    XKB_DEFAULT_LAYOUT = "fr";
  };

  environment.systemPackages = with pkgs; [
    clevis
    globalprotect-openconnect
    openconnect
    tpm2-tools
    wget
    efitools
    curl
    gnupg
    # (import /home/monzey/bonsly/nixos/taegis/default.nix {})
  ];

  # boot.initrd.luks.devices = {
  #   root = {
  #     device = "/dev/disk/by-uuid/<UUID>";
  #     keyFile = "/root/luks-key";
  #   };
  # };

  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [ 80 443 ];
  #   deniedTCPPorts = [ 22 ];
  # };

  systemd.services = {
    # add-luks-key = {
    #   description = "Add LUKS key to Clevis";
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig = {
    #     ExecStart = "${pkgs.clevis}/bin/clevis luks bind -d /dev/<device> tpm2 '{\"pcr_bank\":\"sha256\"}'";
    #   };
    # };

    # globalprotect = {
    #   description = "Install GlobalProtect";
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig = {
    #     ExecStart = "${pkgs.wget}/bin/wget https://github.com/yuezk/GlobalProtect-openconnect/releases/download/v1.4.9/globalprotect-openconnect-1.4.9.tar.gz -O /tmp/globalprotect.tar.gz && \
    #                  tar zxvf /tmp/globalprotect.tar.gz -C /opt && \
    #                  sh /opt/globalprotect-openconnect-1.4.9/scripts/install-ubuntu.sh";
    #   };
    # };

    # taegis-agent = {
    #   description = "Taegis Agent Service";
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig = {
    #     ExecStartPre = "/opt/secureworks/taegis-agent/bin/taegisctl register --key MTQ1NzM3fEZ4NHAyR3FRQWJjbFAtd0JmcUp0SFlR --server reg.e.taegiscloud.com";
    #     ExecStart = "/opt/secureworks/taegis-agent/bin/taegisctl start";
    #     Restart = "always";
    #   };
    # };

    # install-intune = {
    #   description = "Install Microsoft Intune";
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig = {
    #     ExecStart = ''
    #       curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/microsoft.gpg
    #       echo "deb [arch=amd64 signed-by=/etc/microsoft.gpg] https://packages.microsoft.com/ubuntu/24.04/prod noble main" > /etc/apt/sources.list.d/microsoft.list
    #       nix-shell -p apt --run "apt update && apt install -y intune-portal"
    #     '';
    #   };
    # };

    # secure-boot = {
    #   description = "Configure Secure Boot";
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig = {
    #     ExecStart = ''
    #       mokutil --import /opt/ds_agent/secureboot/DS2022.der
    #       mokutil --import /opt/ds_agent/secureboot/DS20_v2.der
    #     '';
    #   };
    # };
  };
}
