dir=$(pwd)

installBasicComponents () {
    apt install -y curl dkms build-essential cmake cmake-data openssh-server linux-headers-`uname -r` alsa-utils
}

installDevEnvironment () {
    # PhpStorm
    wget https://download-cf.jetbrains.com/webide/PhpStorm-2018.3.tar.gz -O /tmp/phpstorm.tar.gz
    mkdir -p /tmp/phpstorm && tar -zxvf /tmp/phpstorm.tar.gz -C /tmp/phpstorm --strip-components=1
    mv /tmp/phpstorm /opt/phpstorm
    ln -s /opt/phpstorm/bin/phpstorm.sh /usr/bin/phpstorm
    chmod a+x /usr/bin/phpstorm

    # virtual box
    wget https://download.virtualbox.org/virtualbox/6.0.0/virtualbox-6.0_6.0.0-127566~Debian~stretch_amd64.deb -O /tmp/virtualbox.deb
    dpkg -i /tmp/virtualbox.deb
    /sbin/vboxconfig

    # Slack
    wget https://downloads.slack-edge.com/linux_releases/slack-desktop-3.3.3-amd64.deb -O /tmp/slack.deb
    dpkg -i /tmp/slack.deb

    apt install -y --fix-broken
    apt install -y openvpn htop

    # Generate a ssh private key to link it to github repos
    ssh-keygen -t rsa -b 4096 -C "maxi.bertrand@gmail.com"
}

installCustomEnvironment () {
    curl -sL https://deb.nodesource.com/setup_10.x | bash -
    apt update

    apt install -y libcairo2-dev libxcb1-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev libxcb-composite0-dev sudo
    apt install -y chromium stow xfonts-base xserver-xorg-input-all xinit xserver-xorg xserver-xorg-video-all cargo ranger zsh zsh-antigen tig feh vim-nox tmux compton i3 suckless-tools xclip silversearcher-ag nodejs bison flex
    apt install -y dbus-x11 libdbus-1-dev libx11-dev libxinerama-dev libxrandr-dev libxss-dev libglib2.0-dev libpango1.0-dev libgtk-3-dev libxdg-basedir-dev dirmngr ffmpeg x11-apps librsvg-2

    npm install -g joplin

    # Install spotify
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
    echo deb http://repository.spotify.com stable non-free | tee /etc/apt/sources.list.d/spotify.list
    apt update
    apt install -y spotify-client

    # Install qutebrowser
    wget http://ftp.fr.debian.org/debian/pool/main/p/pypeg2/python3-pypeg2_2.15.2-2_all.deb -O /tmp/python3.deb
    dpkg -i /tmp/python3.deb

    wget http://ftp.fr.debian.org/debian/pool/main/q/qutebrowser/qutebrowser_1.5.2-1_all.deb -O /tmp/qutebrowser.deb
    dpkg -i /tmp/qutebrowser.deb

    wget http://ftp.fr.debian.org/debian/pool/main/q/qutebrowser/qutebrowser-qtwebengine_1.5.2-1_all.deb -O /tmp/qtwebengine.deb
    dpkg -i /tmp/qtwebengine.deb

    wget https://github.com/advanced-rest-client/arc-electron/releases/download/v12.1.4/arc-linux-12.1.4-amd64.deb -O /tmp/arc.deb
    dpkg -i /tmp/arc.deb

    # Install Chrome
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
    dpkg -i /tmp/chrome.deb

    apt install -y --fix-broken

    # Install dunst
    git clone https://github.com/dunst-project/dunst.git /tmp/dunst
    cd /tmp/dunst
    make
    make install

    # Install rofi
    git clone https://github.com/dunst-project/dunst.git /tmp/rofi
    cd /tmp/rofi
    mkdir build && cd build
    ../configure --disable-check
    make && make install

    # Install rust
    cd /tmp
    apt remove rustc -y
    curl https://sh.rustup.rs -sSf | sh
    source $HOME/.cargo/env
    rustup override set stable
    rustup update stable

    # Install alacritty
    git clone https://github.com/jwilm/alacritty.git alacritty-git
    cd alacritty-git
    git checkout v0.2.1
    cargo build --release
    mv target/release/alacritty /usr/bin
    chmod a+x /usr/bin/alacritty
    rm -rf alacritty-git

    cd $pwd

    # install i3 gaps
    curl -sL https://raw.githubusercontent.com/maestrogerardo/i3-gaps-deb/master/i3-gaps-deb | bash -
    cd i3-gaps
    autoreconf --force --install
    rm -rf build/
    mkdir -p build && cd build/
    ../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
    make
    make install

    rm -rf ../i3-gaps

    # install polybar
    git clone https://github.com/jaagr/polybar.git /tmp/polybar
    cd /tmp/polybar && ./build.sh
    cd ~

    # install zsh plugins manager
    curl -L git.io/antigen > /usr/bin/antigen

    # install fonts
    cp $dir/fonts/* /usr/share/fonts
    fc-cache -fv

    # mv recdsk utility
    cp recdsk /usr/bin
    chmod +x /usr/bin/recdsk
}

usage () {
    echo 'Usage: '$0' [-d] [-c]' 1>&2;exit 1;
}

installBasicComponents;

while getopts :dc opt; do
    case "${opt}" in
        d) 
            installDevEnvironment
            ;;
        c) 
            installCustomEnvironment
            ;;
        *)
            usage
            ;;
    esac
done

