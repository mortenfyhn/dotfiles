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

# Make commands from other terminals available in history searches.
setopt share_history

# Set up "Pure" prompt
fpath+=($HOME/.zsh/pure)
autoload -U promptinit
promptinit
prompt pure
setopt nocaseglob
zstyle ':prompt:pure:prompt:success' color 34  # Green
zstyle ':prompt:pure:prompt:error' color 202   # Red
PURE_PROMPT_SYMBOL='%(?..%? )%B❯%b'            # Nice caret

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

# Keybindings
WORDCHARS=${WORDCHARS//[\/.-]/}                  # Move/delete words one path segment at a time.
bindkey "^[[A" history-beginning-search-backward # Up: recall older prefix matches; empty prefix matches all.
bindkey "^[[B" history-beginning-search-forward  # Down: newer matches, then restore the typed prefix.
bindkey "^[[H" beginning-of-line                 # Home
bindkey "^[[F" end-of-line                       # End
bindkey "^[[1~" beginning-of-line                # Home (alternate encoding)
bindkey "^[[4~" end-of-line                      # End (alternate encoding)
bindkey "^[[1;5C" forward-word                   # Ctrl+Right
bindkey "^[[1;5D" backward-word                  # Ctrl+Left
bindkey "^H" backward-kill-word                  # Ctrl+Backspace
bindkey "^[[3;5~" kill-word                      # Ctrl+Delete

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

# Use c to jump to frequently visited directories, if zoxide is installed.
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd c)"

# Exiting tmux closes the terminal.
if [[ -z "$TMUX" ]] && command -v tmux >/dev/null; then
    exec tmux
fi
