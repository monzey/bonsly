{ config, pkgs, ... }:

{
  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "gardevoir";
  networking.extraHosts =
    ''
      127.0.0.1 api.rg-supervision.local
      127.0.0.1 dashboard.rg-supervision.local
      127.0.0.1 zaza.rg-supervision.local
      127.0.0.1 assist.rg-supervision.local
      127.0.0.1 zaza.staging.rg.gg
    ''
  ;

  # Windows F: keep Steam's existing library path stable across reboots.
  fileSystems."/mnt/F" = {
    device = "/dev/disk/by-uuid/0C52967D52966B6A";
    fsType = "ntfs3";
    options = [
      "uid=1000" "gid=100" "umask=0022" "windows_names"
      "nofail" "x-systemd.automount" "x-systemd.device-timeout=10s"
    ];
  };

  boot.kernel.sysctl = {
    "user.max_user_namespaces" = 10000;
    "fs.inotify.max_user_watches" = 524288; # Souvent nécessaire pour les IDE/OpenCode
    "user.max_mnt_namespaces" = 10000;      # La piste la plus sérieuse ici
    "kernel.unprivileged_userns_clone" = 1;
  };
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  # Steam itself is installed by Home Manager; these integrations need NixOS.
  services.pipewire.alsa.support32Bit = true;
  hardware.steam-hardware.enable = true;

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
