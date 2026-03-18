{ config, inputs, pkgs, unstablePkgs, ... }:

let
  # geminiBin = "${(import ./modules/gemini-cli/gemini.nix { inherit pkgs; })}/bin/gemini-fhs";
  envFile = builtins.readFile ./.env;
  lines = builtins.filter (s: s != "") (builtins.split "\n" envFile);
  getEnv = key: 
    let 
      pattern = "${key}=(.*)";
      matches = builtins.filter (l: !builtins.isList l && builtins.match pattern l != null) lines;
    in 
      if matches == [] 
      then ""
      else builtins.head (builtins.match pattern (builtins.head matches));

  geminiKey = getEnv "GEMINI_API_KEY";
  openaiKey = getEnv "OPENAI_API_KEY";
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
    lsof
    gh-dash
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
    bat
    btop
    vesktop
    neofetch
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

    unstablePkgs.typescript
    unstablePkgs.github-copilot-cli
    unstablePkgs.aider-chat-full
    unstablePkgs.ollama
    unstablePkgs.gemini-cli-bin
    unstablePkgs.slack
    unstablePkgs.vscode
    unstablePkgs.neovim
    unstablePkgs.figma-linux
    (import ./opencode-bin.nix { inherit pkgs; })
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
    ".aider.conf.yml" = { source = ./configs/aider/.aider.conf.yml; };
    ".ssh/" = { source = ./configs/ssh; recursive = true; };
    ".gitconfig" = { source = ./configs/git/.gitconfig; };
    ".gitignore" = { source = ./configs/git/.gitignore; };

    ".local/share/icons/Bibata" = { source = ./configs/cursor; recursive = true; };
    # ".local/bin/gemini" = { source = geminiBin; executable = true; };
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
    OPENAI_API_KEY = openaiKey;
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
