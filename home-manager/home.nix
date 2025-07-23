{ config, inputs, pkgs, unstablePkgs, ... }:

let
  geminiBin = "${(import ./modules/gemini-cli/gemini.nix { inherit pkgs; })}/bin/gemini-fhs";
  envFile = builtins.readFile ./.env;
  geminiKey =
    builtins.head
      (builtins.match "GEMINI_API_KEY=(.*)" envFile);
in {
  imports = [
    ./modules/zsh.nix
    ./modules/hyprland.nix
    ./modules/rofi.nix
    ./scripts/update.nix
    ./scripts/merge.nix
    ./scripts/openvide.nix
    ./scripts/nv.nix
    ./scripts/update-notifier.nix
  ];

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Bibata";
      size = 24;
    };
  };

  nixpkgs.config.allowUnfree = true;

  home.username = "monzey";
  home.homeDirectory = "/home/monzey";

  home.stateVersion = "24.05";
  home.packages = with pkgs; [
    clevis
    git
    gcc
    gh
    python3
    direnv
    fd
    obs-studio
    virtiofsd
    httpie
    httpie-desktop
    lsd
    shotcut
    olive-editor
    rofi-wayland
    eww
    waybar
    libnotify
    hypridle
    teams-for-linux
    brightnessctl
    wl-clipboard
    jq
    wf-recorder
    node2nix
    redisinsight
    waybar
    kitty
    chromium
    firefox
    neovide
    acpi
    (lazygit.overrideAttrs (oldAttrs: {
      version = "0.48.0";
      src = fetchFromGitHub {
        owner = "jesseduffield";
        repo = "lazygit";
        rev = "v0.48.0";
        sha256 = "sha256-L3OcCkoSJZ6skzcjP2E3BrQ39cXyxcuHGthj8RHIGeQ=";
      };
    }))
    gnumake
    delta
    fira-code-nerdfont
    (nerdfonts.override { fonts = [ "VictorMono" ]; })
    nnn
    ripgrep
    slack
    bat
    btop
    vesktop
    neofetch
    unzip
    xplr
    grim
    mako
    slurp
    oxker
    docker
    mkcert
    cassandra
    figma-linux
    pavucontrol
    ferdium
    nodejs_22
    vlc
    ffmpeg
    waybar

    unstablePkgs.vscode
    unstablePkgs.neovim
  ];

  home.file = {
    ".config/nixpkgs" = { source = ./configs/nixpkgs; recursive = true; };
    ".config/bat" = { source = ./configs/bat; recursive = true; };
    ".config/waybar" = { source = ./configs/waybar; recursive = true; };
    ".config/btop" = { source = ./configs/btop; recursive = true; };
    ".config/eww" = { source = ./configs/eww; recursive = true; };
    ".config/kitty" = { source = ./configs/kitty; recursive = true; };
    ".config/lazygit" = { source = ./configs/lazygit; recursive = true; };
    ".config/mako" = { source = ./configs/mako; recursive = true; };
    ".config/rofi" = { source = ./configs/rofi; recursive = true; };
    ".config/nvim" = { source = ./configs/nvim; recursive = true; };
    ".config/xplr" = { source = ./configs/xplr; recursive = true; };
    ".config/neovide" = { source = ./configs/neovide; recursive = true; };
    ".config/openvpn" = { source = ./configs/openvpn; recursive = true; };
    ".ssh/" = { source = ./configs/ssh; recursive = true; };
    ".gitconfig" = { source = ./configs/git/.gitconfig; };
    ".gitignore" = { source = ./configs/git/.gitignore; };

    ".local/share/icons/Bibata" = { source = ./configs/cursor; recursive = true; };
    ".local/bin/gemini" = { source = geminiBin; executable = true; };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  # or
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  # or
  #  /etc/profiles/per-user/monzey/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XKB_DEFAULT_LAYOUT = "fr";
    GEMINI_API_KEY = geminiKey;
  };

  home.sessionPath = [ "$HOME/.local/bin" ];

  systemd.user.services.openvpn-dev = {
    Unit = {
      Description = "OpenVPN connection to dev";
      After = [ "network-online.target" ];
    };

    Service = {
      ExecStart = "${pkgs.openvpn}/bin/openvpn --config ${config.home.homeDirectory}/.config/openvpn/conf.ovpn";
      Restart = "always";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  programs.home-manager.enable = true;
}
