############################################################
# environment                                              #
############################################################

export CC=clang
export CXX=clang++
export PATH="/usr/lib/ccache:$HOME/bin:$PATH"
export ZSH=$HOME/.oh-my-zsh

############################################################
# shell                                                    #
############################################################

ZSH_THEME="bullet-train"
BULLETTRAIN_STATUS_EXIT_SHOW=true
BULLETTRAIN_EXEC_TIME_ELAPSED=1
BULLETTRAIN_PROMPT_CHAR=
BULLETTRAIN_PROMPT_SEPARATE_LINE=false
BULLETTRAIN_PROMPT_ADD_NEWLINE=false
BULLETTRAIN_PROMPT_ORDER=(status custom dir git hg cmd_exec_time)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=2"  # Green autosuggestion text.

plugins=(gitfast thefuck zsh-autosuggestions zsh-256color)

source "$ZSH/oh-my-zsh.sh"

setopt nonomatch

############################################################
# load stuff                                               #
############################################################

if [ -e "$HOME"/.config/dotfiles/secrets.sh ]; then
source "$HOME"/.config/dotfiles/secrets.sh
fi

source "$HOME"/.config/dotfiles/aliases.sh
source "$HOME"/.config/dotfiles/ros.sh
