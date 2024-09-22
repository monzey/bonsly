#! /bin/sh

sudo nixos-generate-config

sudo rm -rf /etc/nixos/configuration.nix
sudo rm -rf /etc/hypr/hyprland.conf

sudo stow bat
# stow dunst
# stow git
# stow ranger
sudo stow wofi
sudo stow greetd
sudo stow nvim
sudo stow zsh
sudo stow lazygit
sudo stow kitty
sudo stow btop
# stow scripts -t /usr
sudo stow nixos -t /etc
sudo stow hyprland

curl -L git.io/antigen > $HOME/.antigen.zsh

chsh -s $(which zsh)
#
# mkdir -p ~/.icons/default
# cp -r cursor/* ~/.icons/default
#
# copy wallpaper
cp wall.png ~/

sudo nixos-rebuild switch
