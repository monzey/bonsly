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

      alias avante='nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'


      # FZF
      eval "$(fzf --zsh)"

      # NOTIFY
      LONG_CMD_THRESHOLD=3
      LONG_CMD_START=""
      LONG_CMD_RUNNING=false

      preexec() {
        LONG_CMD_START=$(date +%s)
        LONG_CMD_RUNNING=true
      }

      precmd() {
        if [[ "$LONG_CMD_RUNNING" = true && -n "$LONG_CMD_START" ]]; then
          local LONG_CMD_END=$(date +%s)
          local DURATION=$((LONG_CMD_END - LONG_CMD_START))
          local EXIT_CODE=$?
          local LAST_COMMAND=$(fc -ln -1)

          if (( DURATION >= LONG_CMD_THRESHOLD )); then
            if (( EXIT_CODE == 0 )); then
              notify-send -u low "  Finished in $DURATION s" "$LAST_COMMAND"
            else
              notify-send -u critical "  Error after $DURATION s" "$LAST_COMMAND"
            fi
          fi

          # Reset state
          LONG_CMD_RUNNING=false
          LONG_CMD_START=""
        fi
      }

      export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' 
      --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
      --color=fg+:#c0caf5,bg+:#1a1b26,hl+:#7dcfff
      --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff 
      --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a'

      # NNN
      export NNN_OPTS="cExH"

      # NVM
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

      # Direnv
      eval "$(direnv hook zsh)"

      # Starship
      eval "$(starship init zsh)"
    '';
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  home.file.".config/starship.toml" = { source = ../configs/starship/starship.toml; recursive = true; };

  home.sessionVariables = {
    EDITOR = "neovide";
    STARSHIP_CONFIG = "$HOME/.config/starship.toml";
  };
}
