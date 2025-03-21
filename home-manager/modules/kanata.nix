{ config, pkgs, ... }:

{
  # Installer Kanata
  home.packages = with pkgs; [
    kanata
  ];

  # Créer un fichier de configuration Kanata avec les options clavier
  home.file.".config/kanata/kanata.kbd".text = ''
    (defsrc
      rshift
      caps)
    
    (deflayermap (default-layer)
      rshift esc
      caps lctl)
  '';

users.groups.uinput = {};
users.users.monzey.extraGroups = ["uinput"];
  # Activer Kanata via un service systemd
  systemd.user.services.kanata = {
    Unit.Description = "Kanata Wayland Session";
    Install.WantedBy = [ "default.target" ];
    Service.ExecStart = "${pkgs.kanata}/bin/kanata";
    Service.Type = "simple";
    Service.Environment = "DISPLAY=:0";
  };
}
