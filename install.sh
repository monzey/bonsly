#! /bin/bash 

pwd=`pwd`

stow alacritty
stow bat
stow compton
stow dunst
stow feh
stow git
stow sway
stow ncmpcpp
stow polybar
stow qutebrowser
stow ranger
stow rofi
stow tern
stow tig
stow tmux
stow vim
stow lvim
stow x
stow zsh
stow lazygit
stow kitty
stow lsd
stow btop
stow xplr

chsh -s $(which zsh)

mkdir -p ~/.icons/cursor-default-theme
cp -r cursor/* ~/.icons/cursor-default-theme

cp $pwd/git-st /usr/bin/git-st
chmod 755 /usr/bin/git-st 

ln -sf $pwd/.fonts.conf ~

# firefox as default web browser 
xdg-settings set default-web-browser firefox-esr.desktop

# alacritty as default terminal
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 60

cd ~
