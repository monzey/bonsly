apt install -y curl build-essential cmake cmake-data libcairo2-dev libxcb1-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev
apt install -y chromium rxvt-unicode stow xfonts-base xserver-xorg-input-all xinit xserver-xorg xserver-xorg-video-all cargo ranger zsh zsh-antigen tig feh vim tmux rofi compton openssh-server git i3 suckless-tools 

# install i3 gaps
curl -sL https://raw.githubusercontent.com/maestrogerardo/i3-gaps-deb/master/i3-gaps-deb | bash -
cd i3-gaps
autoreconf --force --install
rm -rf build/
mkdir -p build && cd build/
../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
make
make install

rm -rf i3-gaps

# install polybar
git clone https://github.com/jaagr/polybar.git /tmp/polybar
cd /tmp/polybar && ./build.sh
cd ~

curl -L git.io/antigen > /usr/bin/antigen
