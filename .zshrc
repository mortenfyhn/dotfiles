# Store history
HISTFILE=~/.history
HISTSIZE=100000
SAVEHIST=100000

# Initialize completions
autoload -Uz compinit
compinit

# Enhanced completion menu
zstyle ':completion:*' menu select

# Fuzzy matching, don't have to type from the start
# zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
setopt complete_in_word
setopt auto_menu # Show all selections for tabbing

# Change directory without typing cd
setopt autocd

# Set up "Pure" prompt
fpath+=($HOME/.zsh/pure)
autoload -U promptinit
promptinit
prompt pure
setopt nocaseglob

# Adjust prompt:
#   %? is the exit code
#   %F sets foreground (text) color
#   34 is a nice green
#   202 is a nice red
#   ❯ is the prompt char
#   %f resets foreground color
#   %B sets bold text, %b resets
PROMPT='%(?.%F{34}.%F{202}%? )%B❯%b%f '

if [[ -f /.dockerenv ]]; then
    PROMPT='%(?.%F{34}.%F{202}%? )🐋 %B❯%b%f '
fi

# Add stuff to PATH
function addtopath() {
    if ! grep -q $1 <<<$PATH; then
        PATH=$PATH:$1
    fi
}
addtopath "$HOME/.local/bin"

# Autosuggestions
autosuggestions_path="$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
if [[ -f "$autosuggestions_path" ]]; then
    source "$autosuggestions_path"
else
    echo "Warning: zsh-autosuggestions not installed"
fi

# Make sure arrow up/down only scrolls history matching what I've already typed
# https://superuser.com/a/585004
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

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
alias gcp='git cherry-pick'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --decorate --oneline --graph'
alias gla='git log --all --decorate --oneline --graph'
alias glas='git log --all --decorate --oneline --graph --simplify-by-decoration'
alias gla20='gla -20'
alias grim='git rebase --interactive master'
alias grom='git rebase master'
alias gs='git status'
alias gsh='git show'
alias j=jotta-cli
alias l=ls
alias lg=lazygit
alias o=xdg-open
alias sa='subl --add'
alias sn='subl --launch-or-new-window'
alias t=trash
alias z='source ~/.zshrc'
alias wip='git add . && git commit -m "wip"'

# Launch Byobu if not already running somewhere (interactive shells only)
case $- in *i*) ;; *) return ;; esac
if command -v byobu >/dev/null && [[ -z "$TMUX" ]] && ! tmux ls >/dev/null && [[ -z "$CI" ]]; then
    exec byobu
fi
