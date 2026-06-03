{ config, inputs, pkgs, unstablePkgs, ... }:

let
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
    ./scripts/watch-dev-sets.nix
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
    libnotify
    lsof
    hypridle
    teams-for-linux
    brightnessctl
    wl-clipboard
    jq
    wf-recorder
    waybar
    chromium
    firefox
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
    nerd-fonts.victor-mono
    nerd-fonts.fira-code
    nnn
    ripgrep
    bat
    btop
    vesktop
    vbam
    unzip
    xplr
    grim
    mako
    slurp
    oxker
    docker
    mkcert
    cassandra
    pavucontrol
    ferdium
    nodejs_22
    vlc
    ffmpeg
    waybar
    inputs.mcp-hub.packages."${system}".default
    deno
    just
    difftastic
    worktrunk
    rofi

    unstablePkgs.firefox-devedition
    unstablePkgs.github-copilot-cli
    unstablePkgs.yazi
    unstablePkgs.devenv
    unstablePkgs.claude-code
    unstablePkgs.superfile
    unstablePkgs.kitty
    unstablePkgs.typescript
    unstablePkgs.github-copilot-cli
    unstablePkgs.ollama
    unstablePkgs.slack
    unstablePkgs.neovide
    unstablePkgs.vscode
    unstablePkgs.codex
    unstablePkgs.neovim
    unstablePkgs.microsoft-edge
    unstablePkgs.quickshell
    unstablePkgs.qt6.qtwayland
    (import ./opencode-bin.nix { inherit pkgs; })
    (import ./cleanup.nix { inherit pkgs; })
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
    ".config/direnv" = { source = ./configs/direnv; recursive = true; };
    ".config/mcphub" = { source = ./configs/mcphub; recursive = true; };
    ".config/opencode" = { source = ./configs/opencode; recursive = true; };
    # ".config/quickshell" = { source = ./configs/quickshell; recursive = true; };
    ".config/superfile" = { source = ./configs/superfile; recursive = true; };
    ".aider.conf.yml" = { source = ./configs/aider/.aider.conf.yml; };
    ".ssh/id_ed25519.pub" = { source = ./configs/ssh/id_ed25519.pub; };
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

  home.activation.sshPrivateKey = config.lib.dag.entryAfter ["writeBoundary"] ''
    install -m 600 "${config.home.homeDirectory}/bonsly/home-manager/configs/ssh/id_ed25519" \
      "${config.home.homeDirectory}/.ssh/id_ed25519"
  '';

  programs.home-manager.enable = true;
}
