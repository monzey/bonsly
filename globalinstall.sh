dir=$(pwd)

installBasicComponents () {
    apt install -y curl dkms build-essential cmake cmake-data openssh-server linux-headers-`uname -r` alsa-utils
}

installDevEnvironment () {
    apt install -y jq graphviz
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

    ln -sf $dir/init.d/openvpncustom /etc/init.d/openvpncustom
    update-rc.d openvpncustom defaults

    # install hub
    wget https://github.com/github/hub/releases/download/v2.12.8/hub-linux-amd64-2.12.8.tgz -O /tmp/hub.tar.gz
    mkdir -p /tmp/hub && tar -zxvf /tmp/hub.tar.gz -C /tmp/hub --strip-components=1
    cd /tmp/hub && ./install

    # install madge
    npm i -g madge

    cd /tmp
    # install git madge
    hub clone jez/git-madge
    cp /tmp/git-madge/git-madge /usr/bin/git-madge
    chmod a+x /usr/bin/git-madge

    # Generate a ssh private key to link it to github repos
    ssh-keygen -t rsa -b 4096 -C "maxi.bertrand@gmail.com"
}

installCustomEnvironment () {
    curl -sL https://deb.nodesource.com/setup_10.x | bash -
    apt update

    apt install -y libcairo2-dev libxcb1-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev libiw-dev libcurl4-openssl-dev libpulse-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev libxcb-composite0-dev sudo
    apt install -y chromium stow xfonts-base xserver-xorg-input-all xinit xserver-xorg xserver-xorg-video-all cargo ranger zsh zsh-antigen tig feh vim-nox tmux compton i3 suckless-tools xclip silversearcher-ag nodejs bison flex
    apt install -y dbus-x11 libdbus-1-dev libx11-dev libxinerama-dev libxrandr-dev libxss-dev libglib2.0-dev libpango1.0-dev libgtk-3-dev libxdg-basedir-dev dirmngr ffmpeg x11-apps librsvg-2 mpc

    npm install -g joplin

    # Install mopidy
    wget -q -O - https://apt.mopidy.com/mopidy.gpg | sudo apt-key add -
    wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/stretch.list
    apt update
    apt install mopidy mopidy-spotify

    # Install iris
    pip3 install Mopidy-Iris
    sudo echo "mopidy ALL=NOPASSWD: /usr/local/lib/python3.5/dist-packages/mopidy_iris/system.sh" >> /etc/sudoers

    # Install spotify
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
    echo deb http://repository.spotify.com stable non-free | tee /etc/apt/sources.list.d/spotify.list
    apt update
    apt install -y spotify-client

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
    cd /tmp
    git clone https://www.github.com/Airblader/i3 i3-gaps
    cd i3-gaps
    git checkout gaps-next && git pull
    autoreconf --force --install
    rm -rf build
    mkdir build
    cd build
    ../configure --prefix=/usr --sysconfdir=/etc
    make && make install

    # install polybar
    git clone https://github.com/jaagr/polybar.git /tmp/polybar
    cd /tmp/polybar && ./build.sh
    cd ~

    # install i3lock color
    apt install libjpeg-dev libpam0g-dev
    git clone https://github.com/PandorasFox/i3lock-color.git /tmp/i3lock-color
    cd /tmp/i3lock-color
    autoreconf --force --install
    mkdir -p build && cd build/
    ../configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --disable-sanitizers
    make

    # install bat
    wget https://github.com/sharkdp/bat/releases/download/v0.12.1/bat-musl_0.12.1_amd64.deb -O /tmp/bat.deb
    dpkg -i /tmp/bat.deb

    # install zsh plugins manager
    curl -L git.io/antigen > /usr/local/bin/antigen

    # install fonts
    cp $dir/fonts/* /usr/share/fonts
    fc-cache -fv

    # mv recdsk utility
    cp recdsk /usr/bin
    chmod +x /usr/bin/recdsk

    # Install ctags 
    git clone https://github.com/romainl/ctags-patterns-for-javascript.git /opt/jsctags
}

# step up in the game
vim () {
    apt remove vim vim-common vim-tiny vim-runtime neovim neovim-runtime
    apt install libncurses5-dev libgnome2-dev libgnomeui-dev \
        libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
        libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
        python3-dev ruby-dev lua5.1 liblua5.1-dev libperl-dev git checkinstall

    cd /tmp
    git clone https://github.com/vim/vim.git
    cd vim
    ./configure --with-features=huge \
        --enable-fail-if-missing \
        --enable-multibyte \
        --enable-rubyinterp=yes \
        --enable-python3interp=dynamic \
        --with-x \
        --with-python3-config-dir=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu \
        --enable-perlinterp=yes \
        --enable-luainterp=yes \
        --enable-cscope \
        --prefix=/usr/local

    make VIMRUNTIMEDIR=/usr/local/share/vim/vim81

    checkinstall
    
    update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
    update-alternatives --set editor /usr/local/bin/vim 
    update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
    update-alternatives --set vi /usr/local/bin/vim 
}

usage () {
    echo 'Usage: '$0' [-d] [-c]' 1>&2;exit 1;
}

# installBasicComponents;

while getopts :vdc opt; do
    case "${opt}" in
        d) 
            installDevEnvironment
            ;;
        v) 
            vim
            ;;
        c) 
            installCustomEnvironment
            ;;
        *)
            usage
            ;;
    esac
done

