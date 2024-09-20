#! /bin/bash 

sudo nixos-generate-config
nix-shell -p stow

sudo rm /etc/nixos/configuration.nix

pwd=`pwd`

# stow bat
# stow dunst
# stow feh
# stow git
# stow ranger
# stow rofi
# stow nvim
# stow zsh
# stow lazygit
stow kitty
# stow lsd
# stow btop
# stow scripts -t /usr
stow nixos -t /etc
stow hyprland -t /etc

sudo nixos-rebuild switch

# chsh -s $(which zsh)
#
# mkdir -p ~/.icons/default
# cp -r cursor/* ~/.icons/default
#
# ln -sf $pwd/.fonts.conf ~
#
# # firefox as default web browser 
# xdg-settings set default-web-browser firefox-esr.desktop
#
# # copy wallpaper
# cp wall.png ~/
#
# # kitty as default terminal
# sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 60
#
# sudo nixos-rebuild switch
#
# cd ~
