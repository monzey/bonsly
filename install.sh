#! /bin/bash 

pwd=`pwd`

stow bat
stow compton
stow dunst
stow feh
stow git
stow sway
stow i3
stow ncmpcpp
stow polybar
stow ranger
stow rofi
stow tern
stow tig
stow vim
stow lvim
stow zsh
stow lazygit
stow kitty
stow lsd
stow btop
stow hyprpaper
stow plasma

chsh -s $(which zsh)

mkdir -p ~/.icons/default
cp -r cursor/* ~/.icons/default

ln -sf $pwd/.fonts.conf ~

# firefox as default web browser 
xdg-settings set default-web-browser firefox-esr.desktop

# copy wallpaper
cp wall.png ~/

# alacritty as default terminal
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 60

cd ~
