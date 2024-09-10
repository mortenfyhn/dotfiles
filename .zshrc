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

# This fixes the vanished git prompt
# https://github.com/ohmyzsh/ohmyzsh/issues/12267
zstyle ':omz:alpha:lib:git' async-prompt no

source "$ZSH/oh-my-zsh.sh"

############################################################
# environment setup                                        #
############################################################

export CC=clang
export CXX=clang++

# Add things to path, but just once
if [[ "$PATH" != *"/usr/lib/ccache"* ]]; then; export PATH="/usr/lib/ccache:$PATH"; fi
if [[ "$PATH" != *"$HOME/.local/bin"* ]]; then; export PATH="$PATH:$HOME/.local/bin"; fi

source ~/.aliases
if [[ -e ~/.zshrc-local ]]; then; source ~/.zshrc-local; fi
