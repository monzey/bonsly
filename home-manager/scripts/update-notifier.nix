{ config, pkgs, ... }:

let
  updateScript = pkgs.writeShellScriptBin "update-with-notifications" ''
  #!/bin/sh
  
  # Send a notification and store its ID
  NOTIF_ID=$(notify-send "Mise à jour du système" "Lancement de la mise à jour..." --print-id)
  
  # Run the update command and capture its success or failure
  # Redirect logs to a temporary file
  if update -hr > /tmp/update-logs.txt 2>&1; then
    # If successful, update the notification
    notify-send "Mise à jour terminée" "Le système est à jour." -r "$NOTIF_ID" -t 5000
  else
    # If it fails, update the notification with an error message
    notify-send "Erreur de mise à jour" "La mise à jour a échoué. Consultez le terminal pour les détails." -r "$NOTIF_ID" -t 10000
  fi
'';
in
{
  home.packages = [ updateScript ];
}


