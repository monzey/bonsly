# GTK portal: reduced motion compatibility

GTK portal 1.15.3 exposes enable-animations but lacks the standard reduced-motion
key. The local patch maps animations enabled to uint32 0 and disabled to uint32 1,
for Read, ReadAll and SettingChanged. Source: upstream 1.15.3 src/settings.c.
https://flatpak.github.io/xdg-desktop-portal/docs/doc-org.freedesktop.portal.Settings.html

Selected only by the gardevoir NixOS overlay. Home Manager declares animations
enabled in the gardevoir host profile. No Milotic-specific desktop API is used.
Remove the patch once the packaged upstream backend supplies the same mapping.

## Applied on 2026-11-05

Patched package and complete gardevoir NixOS configuration build successfully.
The environment blocks sudo (no new privileges), so the NixOS generation has not
been switched. A user service drop-in currently runs the same patched package:

- ~/.config/systemd/user/xdg-desktop-portal-gtk.service.d/90-bonsly-reduced-motion.conf
- ~/.local/state/bonsly/portal-gtk is its Nix GC root.
- dconf /org/gnome/desktop/interface/enable-animations is true.

Read returns 0 for true and 1 for false; live SettingChanged was observed, then
true was restored. The override was reloaded and the GTK service restarted.

After a successful `update -s`, remove only the above user drop-in, reload the
user systemd manager and restart xdg-desktop-portal-gtk.service. Verify the portal
returns 0 before removing the no-longer-needed GC root. `update -h` will also
make the animation preference declarative in the active Home Manager generation.
