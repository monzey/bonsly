{ pkgs }:

# Remove this compatibility patch once GTK exports the standard motion setting.
pkgs.xdg-desktop-portal-gtk.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./portal-gtk-reduced-motion.patch ];
})
