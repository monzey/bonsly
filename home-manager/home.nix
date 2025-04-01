{ config, pkgs, unstablePkgs, ... }:

{
  imports = [
    ./modules/zsh.nix
    ./modules/hyprland.nix
    # @TODO handle this properly
    # ./modules/kanata.nix
    ./modules/i18n.nix
    ./modules/update.nix
    ./modules/openvide.nix
    ./modules/rofi.nix
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
    mako         
    rofi-wayland
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
    slurp
    oxker
    docker
    mkcert
    cassandra
    figma-linux
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

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/monzey/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XKB_DEFAULT_LAYOUT = "fr";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
