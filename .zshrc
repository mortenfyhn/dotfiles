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
# download third party stuff                               #
############################################################

if ! which diff-so-fancy > /dev/null; then
  echo "diff-so-fancy not found, will download..."
  sudo wget -O /usr/local/bin/diff-so-fancy https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy
  sudo chmod +x /usr/local/bin/diff-so-fancy
fi

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
