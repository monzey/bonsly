{ config, pkgs, ... }:

{
  imports = [ ../../configuration.nix ./hardware-configuration.nix ];

  networking.hostName = "muk";
  networking.extraHosts =
    ''
      127.0.0.1 api.rg-supervision.local
      127.0.0.1 dashboard.rg-supervision.local
      127.0.0.1 zaza.rg-supervision.local
      127.0.0.1 local.staging.rg.gg
    ''
  ;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ mesa ];
  };

  environment.sessionVariables = {
    EDITOR = "neovide";
    GBM_BACKENDS_PATH = "${pkgs.mesa}/lib/gbm";
  };
}
