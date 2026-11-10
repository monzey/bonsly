{ config, pkgs, ... }:

{
  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "gardevoir";

  # GTK supplies Settings; Hyprland keeps its existing portal responsibilities.
  nixpkgs.overlays = [
    (final: prev: {
      xdg-desktop-portal-gtk = import ../../packages/portal-gtk.nix { pkgs = prev; };
    })
  ];
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.hyprland = {
    default = [ "hyprland" "gtk" ];
    "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
  };

  networking.extraHosts =
    ''
      127.0.0.1 api.rg-supervision.local
      127.0.0.1 dashboard.rg-supervision.local
      127.0.0.1 zaza.rg-supervision.local
      127.0.0.1 assist.rg-supervision.local
      127.0.0.1 zaza.staging.rg.gg
    ''
  ;

  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/5899a5a9-1797-4c9e-9d05-510fd1304d8e";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.automount" "x-systemd.device-timeout=10s" ];
  };
  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-uuid/c8bdcdde-7711-40e3-a15b-fc3c0845d9d0";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.automount" "x-systemd.device-timeout=10s" ];
  };
  fileSystems."/mnt/misc" = {
    device = "/dev/disk/by-uuid/e9a0b8a1-6c37-410a-b72f-5fbab60a1d43";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.automount" "x-systemd.device-timeout=10s" ];
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

  # GC101 HID usages are sequential, not positional; use the verified Steam layout.
  services.udev.extraHwdb = ''
    evdev:input:b0003v20BCp5656e0111-*
     KEYBOARD_KEY_90001=btn_west
     KEYBOARD_KEY_90002=btn_south
     KEYBOARD_KEY_90003=btn_east
     KEYBOARD_KEY_90004=btn_north
     KEYBOARD_KEY_90005=btn_tl
     KEYBOARD_KEY_90006=btn_tr
     KEYBOARD_KEY_90007=btn_tl2
     KEYBOARD_KEY_90008=btn_tr2
     KEYBOARD_KEY_90009=btn_select
     KEYBOARD_KEY_9000a=btn_start
     KEYBOARD_KEY_9000b=btn_thumbl
     KEYBOARD_KEY_9000c=btn_thumbr
     KEYBOARD_KEY_9000d=btn_mode
  '';

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
}
