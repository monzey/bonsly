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

cp ~/git-st /usr/bin/git-st
chmod /usr/bin/git-st 755

ln -sf $pwd/.fonts.conf ~

cd ~
