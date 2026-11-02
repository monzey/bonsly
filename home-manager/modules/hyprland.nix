{ config, lib, pkgs, ... }:

let
  configDir = ../configs/hyprland;
in {
  options.bonsly.host = lib.mkOption {
    type = lib.types.enum [ "muk" "gardevoir" ];
    description = "Bonsly machine profile, selected by the Home Manager flake output.";
  };

  config = {
    home.packages = with pkgs; [
      wayland
      wayland-protocols
      wlroots
      xwayland
      hyprshot
    ];

    home.file = (lib.mapAttrs' (name: _: lib.nameValuePair ".config/hypr/${name}" {
      source = configDir + "/${name}";
      recursive = true;
    }) (lib.filterAttrs (name: _: name != "hyprland.lua" && name != "hosts")
      (builtins.readDir configDir))) // {
      ".config/hypr/hyprland.lua".source = pkgs.writeText "hyprland-${config.bonsly.host}.lua" (
        builtins.readFile (configDir + "/hosts/${config.bonsly.host}.lua")
        + "\n"
        + builtins.readFile (configDir + "/hyprland.lua")
      );
    };
  };
}
