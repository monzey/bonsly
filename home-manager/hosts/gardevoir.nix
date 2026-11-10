{ lib, pkgs, ... }:

{
  imports = [ ../home.nix ../modules/rtk ];
  bonsly.host = "gardevoir";
  dconf.settings."org/gnome/desktop/interface".enable-animations = true;
  home.packages = [ pkgs.steam pkgs.prismlauncher ];

  home.file.".config/caelestia/shell.json".source = lib.mkForce (
    pkgs.writeText "caelestia-gardevoir-shell.json" (builtins.toJSON (
      lib.recursiveUpdate
        (builtins.fromJSON (builtins.readFile ../configs/caelestia/shell.json))
        {
          general.idle = {
            lockBeforeSleep = false;
            timeouts = [
              { timeout = 300; idleAction = "dpms off"; returnAction = "dpms on"; }
              { timeout = 600; idleAction = [ "suspendThenHibernate" ]; }
            ];
          };
        }
    ))
  );
  home.file.".config/hypr/hypridle.conf".source = lib.mkForce (
    pkgs.writeText "hypridle-gardevoir.conf" (builtins.replaceStrings
      [
        "    before_sleep_cmd = caelestia-ipc lock lock\n"
        "listener {\n    timeout = 150                                # 2.5min.\n    on-timeout = caelestia-ipc lock lock\n}\n"
      ]
      [ "" "" ]
      (builtins.readFile ../configs/hyprland/hypridle.conf))
  );
}
