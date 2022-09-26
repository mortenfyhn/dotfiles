DOTFILES="${HOME}/.config/dotfiles"

function source_if_found { [[ -f "$1" ]] && source "$1"; }

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

plugins=(gitfast zsh-autosuggestions zsh-256color)

source "$ZSH/oh-my-zsh.sh"

setopt nonomatch

############################################################
# environment                                              #
############################################################

source "$DOTFILES"/env-shared.sh
source_if_found "$DOTFILES"/env-machine-specific.sh
source "$DOTFILES"/aliases.sh

############################################################
# keyboard                                                 #
############################################################

# Make sure AltGr + Space produces normal, not non-breaking, space.
command -v setxkbmap > /dev/null && setxkbmap -option "nbsp:none"
