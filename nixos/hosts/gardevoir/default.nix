{ config, pkgs, ... }:

{
  imports = [ ../../configuration.nix ./hardware-configuration.nix ];

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
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
