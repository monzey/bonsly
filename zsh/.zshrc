# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
source /usr/local/bin/antigen

antigen use oh-my-zsh

antigen bundle git
antigen bundle heroku
antigen bundle vi-mode
antigen bundle commant-not-found
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle molovo/crash
antigen bundle desyncr/auto-ls
antigen bundle voronkovich/symfony.plugin.zsh
antigen bundle lambda-mod-zsh-theme
antigen bundle wfxr/forgit
antigen theme romkatv/powerlevel10k

antigen apply

# source $HOME/dotfiles/.purepower
ZSH_THEME="powerlevel10k/powerlevel10k"

KEYTIMEOUT=1
# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
DEFAULT_USER="monzey"

# auto-ls config
auto-ls-exa () {
  exa
}

auto-ls-st () {
	git st
}

AUTO_LS_COMMANDS=(exa st)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Vim as default editor
export EDITOR=vim
export PATH=$PATH:/usr/lib/dart/bin
export PATH=$PATH:$HOME/.pub-cache/bin
export PATH=$PATH:$HOME/.cargo/bin
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH=$PATH:$HOME/.rvm/bin

alias gco='git checkout `(git branch -a & git tag) | fzf`'
# alias gp='git push `git branch | fzf`'
# alias gl='git pull `git branch | fzf`'
alias gn='git checkout -b $@'
alias gc='ga && git commit'

alias core='cd ~/rg/rgsupv-core && vim'
alias dash='cd ~/rg/rgsupv-dashboard && vim'
alias dbox='cd ~/rg/devbox > /dev/null 2>&1 && vagrant ssh'
alias repack='~/dotfiles/pack'

alias ls='exa'
alias lg='lazygit'

# fzf completion and key bindings
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh

# rofi bins
export PATH=$HOME/.config/rofi/bin:$PATH

# go bin
export PATH=/usr/local/go/bin:$PATH

# go apps
export PATH=~/go/bin:$PATH

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
