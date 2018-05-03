############################################################
# ZSH theme                                                #
############################################################

ZSH_THEME="bullet-train"
BULLETTRAIN_STATUS_EXIT_SHOW=true
BULLETTRAIN_EXEC_TIME_ELAPSED=1
BULLETTRAIN_PROMPT_CHAR=
BULLETTRAIN_PROMPT_SEPARATE_LINE=false
BULLETTRAIN_PROMPT_ADD_NEWLINE=false
BULLETTRAIN_PROMPT_ORDER=(status custom dir git hg cmd_exec_time)

############################################################
# oh-my-zsh stuff                                          #
############################################################

plugins=(zsh-autosuggestions zsh-256color)

export ZSH=$HOME/.oh-my-zsh
export ZSH_CUSTOM=$ZSH_CUSTOM
source $ZSH/oh-my-zsh.sh

############################################################
# download third party stuff                               #
############################################################

if [ ! -f $ZSH_CUSTOM/themes/bullet-train.zsh-theme ]; then
  echo "bullet-train ZSH theme not found, will download..."
  wget -O $ZSH_CUSTOM/themes/bullet-train.zsh-theme https://raw.githubusercontent.com/mortenfyhn/bullet-train.zsh/master/bullet-train.zsh-theme
  source $HOME/.zshrc  # Recursive zshrc, nice.
fi

if ! which diff-so-fancy > /dev/null; then
  echo "diff-so-fancy not found, will download..."
  sudo wget -O /usr/local/bin/diff-so-fancy https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy
  sudo chmod +x /usr/local/bin/diff-so-fancy
fi

if ! fc-list | grep -i "InputMono-Regular" > /dev/null; then
  echo "Input Mono font not found, download here:\n"
  echo "http://input.fontbureau.com/download/?customize&fontSelection=whole&a=0&g=ss&i=0&l=0&zero=0&asterisk=height&braces=0&preset=default&line-height=1&email=\n"
  echo "Just open the archive and copy the <InputMono> directory to ~/.fonts"
fi

############################################################
# load stuff                                               #
############################################################

source $HOME/.config/custom-secrets.sh
source $HOME/.config/custom-aliases.sh
source $HOME/.config/custom-functions.sh

source $HOME/.config/custom-dune-config.sh
source $HOME/.config/custom-ino-config.sh
source $HOME/.config/custom-ros-config.sh

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
