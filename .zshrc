############################################################
# Theme                                                    #
############################################################

ZSH_THEME="bullet-train"

BULLETTRAIN_STATUS_EXIT_SHOW=true
BULLETTRAIN_EXEC_TIME_ELAPSED=1

BULLETTRAIN_PROMPT_CHAR=
BULLETTRAIN_PROMPT_SEPARATE_LINE=false
BULLETTRAIN_PROMPT_ADD_NEWLINE=false

BULLETTRAIN_VIRTUALENV_FG=black

BULLETTRAIN_PROMPT_ORDER=(
  # time
  status
  custom
  # context
  dir
  perl
  ruby
  virtualenv
  # nvm
  aws
  go
  elixir
  git
  hg
  cmd_exec_time
)

############################################################
# oh-my-zsh stuff                                          #
############################################################

plugins=(zsh-autosuggestions zsh-256color)

export ZSH=$HOME/.oh-my-zsh
export ZSH_CUSTOM=$ZSH_CUSTOM
source $ZSH/oh-my-zsh.sh

############################################################
# load stuff                                               #
############################################################

source $HOME/.dunerc
source $HOME/.aliases
source $HOME/.functions
source $HOME/.inorc
source $HOME/.rosrc

############################################################
# path stuff                                               #
############################################################

# Add conda to path if it isn't there already
if ! find_in_path 'conda'; then
  PATH_ORIGINAL=$PATH
  if [ -d "$HOME/miniconda3/" ]; then
    PATH_WITH_CONDA="$HOME/miniconda3/bin:$PATH"
  elif [ -d "$HOME/anaconda3/" ]; then
    PATH_WITH_CONDA="$HOME/anaconda3/bin:$PATH"
  fi
  # export PATH=$PATH_WITH_CONDA
fi

export PATH=$PATH:$HOME/bin
