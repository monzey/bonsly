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

# theme

POWERLEVEL9K_PROMPT_ON_NEWLINE=true
# POWERLEVEL9K_RPROMPT_ON_NEWLINE=true

# POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND='black'
# POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND='009'
# 
# POWERLEVEL9K_DIR_HOME_BACKGROUND='009'
# POWERLEVEL9K_DIR_HOME_FOREGROUND='black'
# 
# POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='196'
# POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='232'

# POWERLEVEL9K_VCS_CLEAN_FOREGROUND='099'
# POWERLEVEL9K_MODE='awesome-fontconfig'

#Icon config
POWERLEVEL9K_HOME_ICON='\Ue617'
POWERLEVEL9K_SUB_ICON=''
POWERLEVEL9K_DIR_ICON=''
POWERLEVEL9K_SSH_ICON=''
POWERLEVEL9K_SSH_ICON=''
POWERLEVEL9K_SSH_BACKGROUND='082'
POWERLEVEL9K_SSH_FOREGROUND='022'
POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND='040'
POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND='016'
POWERLEVEL9K_CONTEXT_REMOTE_BACKGROUND='197'
POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND='016'
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=""
POWERLEVEL9K_VCS_GIT_GITHUB_ICON=' '

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context ssh dir dir_writable vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status vi_mode)

KEYTIMEOUT=1
# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
DEFAULT_USER="maxime"

# auto-ls config
auto-ls-exa () {
  exa
}

auto-ls-st () {
	git status -sb
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

[ -f ~/.config/fzf/fzf.zsh ] && source ~/.config/fzf/fzf.zsh
