#! /bin/bash 

pwd=`pwd`

stow alacritty
stow autostart
stow bat
stow compton
stow dunst
stow feh
stow git
stow i3
stow ncmpcpp
stow polybar
stow qutebrowser
stow ranger
stow rofi
stow tern
stow tig
stow tmux
stow vim
stow nvim
stow x
stow zsh

chsh -s $(which zsh)

folder=`~/.tmux/plugins/tpm`

if [ ! -d "$folder" ] ; then
  git clone https://github.com/tmux-plugins/tpm "$folder"
fi

mkdir -p ~/.icons/cursor-default-theme
cp -r cursor/* ~/.icons/cursor-default-theme

cp $pwd/git-st /usr/bin/git-st
chmod 755 /usr/bin/git-st 

ln -sf $pwd/.fonts.conf ~

# google-chrome as default web browser 
xdg-settings set default-web-browser google-chrome.desktop

# alacritty as default terminal
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 60

cd ~
