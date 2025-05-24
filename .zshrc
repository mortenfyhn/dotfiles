# Store history
HISTFILE=~/.history
HISTSIZE=100000
SAVEHIST=100000

# Initialize completions
autoload -Uz compinit; compinit

# Cd without typing cd
setopt autocd

# Set up "Pure" prompt
fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure
setopt nocaseglob
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
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
alias d=dnf
alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias ga='git add'
alias gcan='git commit --amend --no-edit'
alias gchb='git checkout -b'
alias gcm='git commit -m'
alias gd='git diff'
alias gds='git diff --staged'
alias gla='git log --all --decorate --oneline --graph'
alias grim='git rebase --interactive master'
alias grom='git rebase master'
alias gs='git status'
alias gsh='git show'
alias j=jotta-cli
alias l=ls
alias o=xdg-open
alias t=trash
alias z='source ~/.zshrc'
alias sn='subl -n'
