# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
source /usr/local/bin/antigen

antigen use oh-my-zsh

antigen bundle git
antigen bundle heroku
antigen bundle commant-not-found
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle molovo/crash
antigen bundle desyncr/auto-ls
antigen bundle voronkovich/symfony.plugin.zsh
antigen bundle lambda-mod-zsh-theme
antigen theme romkatv/powerlevel10k

antigen apply

source $HOME/dotfiles/.purepower

KEYTIMEOUT=1
# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
DEFAULT_USER="maxime"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# Vim as default editor
export EDITOR=vim
export PATH=$PATH:/usr/lib/dart/bin
export PATH=$PATH:~/.pub-cache/bin
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH=$PATH:$HOME/.rvm/bin
export PATH=$PATH:$HOME/.cargo/bin
