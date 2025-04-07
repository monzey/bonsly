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
    ./scripts/openvide.nix
    ./scripts/node.nix
    ./scripts/rust.nix

    inputs.hyprpanel.homeManagerModules.hyprpanel
  ];

  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "monzey";
  home.homeDirectory = "/home/monzey";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    git
    qemu
    quickemu
    rofi-wayland
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
    ranger
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
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    unstablePkgs.vscode
    unstablePkgs.neovim
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    ".config/bat" = { source = ./configs/bat; recursive = true; };
    ".config/btop" = { source = ./configs/btop; recursive = true; };
    ".config/kitty" = { source = ./configs/kitty; recursive = true; };
    ".config/lazygit" = { source = ./configs/lazygit; recursive = true; };
    ".config/mako" = { source = ./configs/mako; recursive = true; };
    ".config/rofi" = { source = ./configs/rofi; recursive = true; };
    ".config/nvim" = { source = ./configs/nvim; recursive = true; };
    ".config/xplr" = { source = ./configs/xplr; recursive = true; };
    ".ssh/" = { source = ./configs/ssh; recursive = true; };
    ".gitconfig" = { source = ./configs/git/.gitconfig; };
    ".gitignore" = { source = ./configs/git/.gitignore; };

    ".local/share/icons/Bibata" = { source = ./configs/cursor; recursive = true; };

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  programs.hyprpanel = {
    # Enable the module.
    # Default: false
    enable = false;

    # Add '/nix/store/.../hyprpanel' to your
    # Hyprland config 'exec-once'.
    # Default: false
    hyprland.enable = true;

    # Fix the overwrite issue with HyprPanel.
    # See below for more information.
    # Default: false
    overwrite.enable = true;

    settings = {
      bar.customModules.updates.pollingInterval = 1440000;
      theme.bar.floating = false;
      scalingPriority = "gdk";
      theme.bar.scaling = 75;
      bar.media.show_active_only = true;
      theme.bar.transparent = true;
      theme.bar.buttons.y_margins = "0.3em";
      theme.osd.scaling = 100;
      theme.bar.menus.menu.dashboard.scaling = 75;
      theme.bar.menus.menu.bluetooth.scaling = 95;
      theme.bar.menus.menu.network.scaling = 95;
      theme.bar.menus.menu.volume.scaling = 95;
      theme.bar.menus.menu.media.scaling = 95;
      theme.bar.menus.menu.dashboard.confirmation_scaling = 95;
      menus.dashboard.shortcuts.left.shortcut1.command = "firefox";
      menus.dashboard.shortcuts.left.shortcut1.icon = "";
      menus.dashboard.shortcuts.left.shortcut1.tooltip = "Firefox";
      menus.dashboard.directories.enabled = false;
      menus.dashboard.shortcuts.right.shortcut3.command = "hyprshot -m window";
      menus.dashboard.shortcuts.left.shortcut4.command = "wofi --show drun";
      theme.osd.enable = true;
      theme.osd.location = "bottom";
      theme.osd.orientation = "horizontal";
      theme.osd.margins = "0px 5px 10px 0px";
      menus.power.lowBatteryNotification = true;
    };
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
