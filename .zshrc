############################################################
# ZSH setup                                                #
############################################################

export ZSH=$HOME/.oh-my-zsh

# Set up prompt
ZSH_THEME="bullet-train"
BULLETTRAIN_STATUS_EXIT_SHOW=true
BULLETTRAIN_EXEC_TIME_ELAPSED=1
BULLETTRAIN_PROMPT_CHAR=
BULLETTRAIN_PROMPT_SEPARATE_LINE=false
BULLETTRAIN_PROMPT_ADD_NEWLINE=false
BULLETTRAIN_PROMPT_ORDER=(status custom dir git hg cmd_exec_time)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=2"  # Green autosuggestion text.

# Distinct prompt in Docker
if [[ -f /.dockerenv ]]
then
    BULLETTRAIN_DIR_BG=cyan
    BULLETTRAIN_PROMPT_CHAR=🐋
fi

plugins=(
    git
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

############################################################
# environment setup                                        #
############################################################

export CC=clang
export CXX=clang++

# Add ccache to path
[[ ! "$PATH" =~ /usr/lib/ccache ]] && export PATH="/usr/lib/ccache:$PATH"

# Add ~/.local/bin to path
[[ ! "$PATH" =~ "$HOME/.local/bin" ]] && export PATH="$PATH:$HOME/.local/bin"

source ~/.aliases
[[ -e ~/.zshrc-local ]] && source ~/.zshrc-local

############################################################
# ROS                                                      #
############################################################

# shellcheck disable=SC2016
export ROSCONSOLE_FORMAT='[${severity}] [${node}] [${time}]: ${message}'
