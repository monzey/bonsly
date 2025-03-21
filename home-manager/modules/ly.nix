{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ly
  ];

  home.file.".config/ly/config.ini".text = ''
    [session]
    sessionCommand = Hyprland
  '';

  # Service pour Ly
  systemd.user.services.ly = {
    Unit.Description = "Ly Display Manager";
    Install.WantedBy = [ "graphical.target" ];
    Service.ExecStart = "${pkgs.ly}/bin/ly";
  };

  xsession.enable = false;
}
