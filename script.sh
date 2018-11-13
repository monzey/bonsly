apt install -y curl build-essential cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev
apt install -y chromium stterm stow nodm xfonts-base xserver-xorg-input-all xinit xserver-xorg xserver-xorg-video-all cargo ranger zsh zsh-antigen tig feh vim tmux rofi compton openssh-server git i3 suckless-tools 

# install i3 gaps
curl -sL https://raw.githubusercontent.com/maestrogerardo/i3-gaps-deb/master/i3-gaps-deb | bash -

# install polybar
git clone https://github.com/jaagr/polybar.git /tmp/polybar
cd /tmp/polybar && ./build.sh
cd ~

chsh -s $(which zsh)
curl -L git.io/antigen > /usr/bin/antigen
