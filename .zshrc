# Store history
HISTFILE=~/.history
HISTSIZE=100000
SAVEHIST=100000

# Initialize completions
autoload -Uz compinit
compinit

# Repeated Tab cycles through completion candidates.
zstyle ':completion:*' menu select

# Ignore case; try prefix matches first, then matches within names.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'm:{a-zA-Z}={A-Za-z} r:|=*' 'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*'
setopt complete_in_word

# Change directory without typing cd
setopt autocd

# Share history between tmux sessions
setopt inc_append_history

# Set up "Pure" prompt
fpath+=($HOME/.zsh/pure)
autoload -U promptinit
promptinit
prompt pure
setopt nocaseglob

# Bold caret: green on success, red with the exit code on failure.
zstyle ':prompt:pure:prompt:success' color 34
zstyle ':prompt:pure:prompt:error' color 202
PURE_PROMPT_SYMBOL='%(?..%? )%B❯%b'

# Show git stash
zstyle :prompt:pure:git:stash show yes

# Keep the Git branch readable on a dark background.
zstyle ':prompt:pure:git:branch' color 7

# Autosuggestions
autosuggestions_path="$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
if [[ -f "$autosuggestions_path" ]]; then
    source "$autosuggestions_path"
else
    echo "Warning: zsh-autosuggestions not installed"
fi

# Type a prefix (e.g. cd), then Up/Down cycles through matching history,
# newest first, without executing it. With no prefix, browse all history.
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# Home/End keys
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[1~" beginning-of-line # Alternative Home
bindkey "^[[4~" end-of-line       # Alternative End

# Treat / . - as word separators so word jumping and deletion step through
# path segments one at a time instead of swallowing a whole path.
WORDCHARS=${WORDCHARS//[\/.-]/}

# Ctrl+Left/Right for word jumping
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Ctrl+Backspace/Delete for word deletion
bindkey "^H" backward-kill-word
bindkey "^[[3;5~" kill-word

# Aliases
alias ...='cd ../..'
alias ....='cd ../../..'
alias cl=claude
alias d=dots
alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias ga='git add'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
# Delete local branches whose upstream is gone (merged + remote auto-deleted). -D since squash merges hide the merge from branch -d.
alias gbgone='git fetch --prune && git branch -vv | grep ": gone]" | awk "{print \$1}" | xargs -r git branch -D'
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
alias gs='git status'
alias gsh='git show'
alias j=jotta-cli
alias l=ls
alias la='ls -a'
alias lg=lazygit
alias o=xdg-open
alias sa='subl --add'
alias sn='subl --launch-or-new-window'
alias t=trash
alias z='source ~/.zshrc'
alias wip='git add . && git commit -m "wip"'

# Installing bat on Ubuntu gives "batcat"...
if command -v batcat >/dev/null; then
    alias bat=batcat
fi

# Add stuff to PATH
path+=("$HOME/.local/bin")
typeset -U path

# Local machine-specific setup, not tracked.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Non-interactive shells: bail out early.
case $- in *i*) ;; *) return ;; esac

# Launch tmux in all new terminals
if [[ -z "$TMUX" ]] && command -v tmux >/dev/null; then
    tmux new-session
fi

# Guarded, so a machine without zoxide doesn't error on every shell
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd c)"
