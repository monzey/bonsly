{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    antigen
    starship
    fzf
    eza
  ];

  home.file.".bash_profile".text = ''
    exec ${pkgs.zsh}/bin/zsh
  '';

  home.file.".zprofile".text = ''
    exec ${pkgs.zsh}/bin/zsh
  '';

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    autosuggestion.enable = true;
    defaultKeymap = "emacs";

    initExtra = ''
      # Aliases
      DEFAULT_USER="monzey"

      alias ls='eza'
      alias lt='eza --tree'
      alias lla='ls -la'
      alias lg='lazygit'

      # auto-ls config
      auto-ls-lla () {
        eza -la
      }

      alias gco='git checkout `(git branch -a & git tag) | fzf`'
      # alias gp='git push `git branch | fzf`'
      # alias gl='git pull `git branch | fzf`'
      alias gn='git checkout -b $@'
      alias gc='ga && git commit'
      alias gnm='git fetch origin && git checkout origin/master && git checkout -b'
      alias gnb='git fetch origin && git checkout `(git branch -a) | fzf` && git checkout -b'
      alias gdel='git branch -D `(git branch) | fzf`'

      alias core='neovide ~/rg/rgsupv-core'
      alias dash='neovide ~/rg/rgsupv-dashboard'

      alias ssh='kitty +kitten ssh'

      # FZF
      eval "$(fzf --zsh)"

      export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' 
      --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
      --color=fg+:#c0caf5,bg+:#1a1b26,hl+:#7dcfff
      --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff 
      --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a'

      # NNN
      export NNN_OPTS="cErxH"

      # NVM
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

      # Starship
      eval "$(starship init zsh)"
    '';
  };


  home.file.".config/starship.toml" = { source = ../configs/starship/starship.toml; recursive = true; };

  home.sessionVariables = {
    EDITOR = "neovide";
    STARSHIP_CONFIG = "$HOME/.config/starship.toml";
  };
}
