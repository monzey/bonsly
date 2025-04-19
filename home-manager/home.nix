{ config, inputs, pkgs, unstablePkgs, ... }:

{
  imports = [
    ./modules/zsh.nix
    ./modules/hyprland.nix
    # @TODO handle this properly
    # ./modules/kanata.nix
    ./modules/i18n.nix
    ./modules/rofi.nix

    ./scripts/update.nix
    # ./scripts/merge.nix
    ./scripts/openvide.nix
    ./scripts/node.nix
    ./scripts/rust.nix

    inputs.hyprpanel.homeManagerModules.hyprpanel
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "monzey";
  home.homeDirectory = "/home/monzey";

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    clevis
    git
    gcc
    obs-studio
    rofi-wayland
    waybar
    hypridle
    teams-for-linux
    brightnessctl
    wl-clipboard
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
    nnn
    ripgrep
    slack
    bat
    btop
    discord
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
    pipewire
    wireplumber
    pavucontrol
    ferdium
    nodejs_22
    vlc
    ffmpeg

    unstablePkgs.vscode
    unstablePkgs.neovim
  ];

  home.file = {
    ".config/nixpkgs" = { source = ./configs/nixpkgs; recursive = true; };
    ".config/bat" = { source = ./configs/bat; recursive = true; };
    ".config/btop" = { source = ./configs/btop; recursive = true; };
    ".config/kitty" = { source = ./configs/kitty; recursive = true; };
    ".config/lazygit" = { source = ./configs/lazygit; recursive = true; };
    ".config/mako" = { source = ./configs/mako; recursive = true; };
    ".config/rofi" = { source = ./configs/rofi; recursive = true; };
    ".config/nvim" = { source = ./configs/nvim; recursive = true; };
    ".config/xplr" = { source = ./configs/xplr; recursive = true; };
    ".config/openvpn" = { source = ./configs/openvpn; recursive = true; };
    ".config/waybar" = { source = ./configs/waybar; recursive = true; };
    ".config/obs-studio" = { source = ./configs/obs; recursive = true; };
    ".ssh/" = { source = ./configs/ssh; recursive = true; };
    ".gitconfig" = { source = ./configs/git/.gitconfig; };
    ".gitignore" = { source = ./configs/git/.gitignore; };

    ".local/share/icons/Bibata" = { source = ./configs/cursor; recursive = true; };
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
  };

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
