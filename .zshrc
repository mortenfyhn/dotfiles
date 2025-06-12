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
zstyle ':prompt:pure:prompt:success' color 34  # Greener green
zstyle ':prompt:pure:prompt:error' color 202  # Redder red

# Add stuff to PATH
function addtopath() {
  if ! grep -q $1 <<<$PATH
  then
    PATH=$PATH:$1
  fi
}
addtopath "$HOME/.local/bin"

# Autosuggestions
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Aliases
alias d=dots
alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias ga='git add'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
alias gcan='git commit --amend --no-edit'
alias gch='git checkout'
alias gchb='git checkout -b'
alias gcm='git commit -m'
alias gd='git diff'
alias gds='git diff --staged'
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
