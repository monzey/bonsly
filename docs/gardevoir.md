# gardevoir host notes

Paths below are relative to the Bonsly root. These notes describe the declared configuration;
activation and hardware checks are separate steps.

## Boot

gardevoir uses UEFI GRUB (at most 2 generations on the 512 MiB ESP, 3-second menu, Catppuccin Mocha,
1280×720 preferred for menu responsiveness) and Plymouth with adi1090x `cuts_alt`, configured in
`nixos/hosts/gardevoir/default.nix`; muk retains the shared systemd-boot configuration. Boot
appearance must be checked after reboot.

## Storage

gardevoir mounts its ext4 data partitions by filesystem UUID at `/mnt/games` (Crucial BX500),
`/mnt/media` (Toshiba MQ04UBF100) and `/mnt/misc` (Samsung 860 EVO), declared in
`nixos/hosts/gardevoir/default.nix`. They use systemd automount and tolerate absent drives; ext4
ownership is stored on disk, not set through mount options.

## Locking

gardevoir disables automatic locking (idle and before sleep) through host-specific Caelestia and
hypridle overrides in `home-manager/hosts/gardevoir.nix`; manual locking and other idle actions
remain available.

## Games

Steam and Prism Launcher are installed only by `home-manager/hosts/gardevoir.nix`; the games disk
replaces the former Windows F disk; use `/mnt/games` for Steam and Prism data (launcher
configuration stays in the Linux home); `nixos/hosts/gardevoir/default.nix` supplies 32-bit
graphics/audio and Steam hardware rules, without enabling `programs.steam`.

## Reduced motion portal

gardevoir exports the standard `org.freedesktop.appearance/reduced-motion` portal setting through a
GTK compatibility patch in `nixos/packages/portal-gtk.nix` and `nixos/packages/portal-gtk-reduced-motion.patch`,
selected by the host overlay. It maps the existing `org.gnome.desktop.interface/enable-animations`
preference (Home Manager host profile) to 0/1 and emits live changes; remove the patch when upstream
provides this mapping.

## GC101 controller

gardevoir remaps the GC101 Controller 1.03 (`20bc:5656`, revision `0111`) HID button usages to
positional Linux gamepad codes via `services.udev.extraHwdb` in `nixos/hosts/gardevoir/default.nix`.
This applies outside Steam, including Firefox. After activation, reconnect the controller and
reconfigure any Steam custom input mapping if needed; joydev button indices may change. Axes are
unchanged.

The same host exports `SDL_GAMECONTROLLERCONFIG` for the GC101's normalized Linux layout: X/Y use
button indices 3/2, digital L2/R2 use 6/7, and guide/stick clicks use 10/11/12. This complements
hwdb for SDL applications; it does not override application-owned mappings. Log out and back in
after a system switch to propagate session variables.
