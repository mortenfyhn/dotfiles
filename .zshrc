# Store history
HISTFILE=~/.history
HISTSIZE=100000
SAVEHIST=100000

# Initialize completions
autoload -Uz compinit; compinit

# Enhanced completion menu
zstyle ':completion:*' menu select

# Fuzzy matching, don't have to type from the start
# zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
setopt complete_in_word
setopt auto_menu  # Show all selections for tabbing

# Change directory without typing cd
setopt autocd

# Set up "Pure" prompt
fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure
setopt nocaseglob

# Adjust prompt:
#   %? is the exit code
#   %F sets foreground (text) color
#   34 is a nice green
#   202 is a nice red
#   ❯ is the prompt char
#   %f resets foreground color
PROMPT='%(?.%F{34}.%F{202}%? )❯%f '

# Add stuff to PATH
function addtopath() {
  if ! grep -q $1 <<<$PATH
  then
    PATH=$PATH:$1
  fi
}
addtopath "$HOME/.local/bin"

# Autosuggestions
file="$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"; [[ -f $file ]] && source $file
file="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"; [[ -f $file ]] && source $file

# Make sure arrow up only scrolls history matching what I've already typed
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "${key[Up]}" up-line-or-beginning-search
bindkey "${key[Down]}" down-line-or-beginning-search

# Aliases
alias d=dots
alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias ga='git add'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gch='git checkout'
alias gchb='git checkout -b'
alias gcm='git commit -m'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --decorate --oneline --graph'
alias gla='git log --all --decorate --oneline --graph'
alias gla20='gla -20'
alias grim='git rebase --interactive master'
alias grom='git rebase master'
alias gs='git status'
alias gsh='git show'
alias j=jotta-cli
alias l=ls
alias lg=lazygit
alias o=xdg-open
alias sn='subl -n'
alias t=trash
alias z='source ~/.zshrc'
alias wip='git add . && git commit -m "wip"'

# Slow as shit:
#
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
