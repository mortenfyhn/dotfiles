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

# Share history between tmux sessions
setopt inc_append_history

# Set up "Pure" prompt
fpath+=($HOME/.zsh/pure)
autoload -U promptinit
promptinit
prompt pure
setopt nocaseglob

# Customize Pure's caret without reassigning PROMPT: current Pure bakes the path
# and git info into PROMPT, so overriding it wipes them out (leaving only a caret).
# Drive Pure's own knobs instead. Caret is green on success, red with the exit
# code on failure (%? is the exit code; 34 is a nice green, 202 a nice red).
zstyle ':prompt:pure:prompt:success' color 34
zstyle ':prompt:pure:prompt:error' color 202
PURE_PROMPT_SYMBOL='%(?..%? )%B❯%b'

if [[ -f /.dockerenv ]]; then
    PURE_PROMPT_SYMBOL='%(?..%? )🐋 %B❯%b'
fi

# Show git stash
zstyle :prompt:pure:git:stash show yes

# Pure's default git branch color (242) is too dim on a dark background. Use the
# theme's normal foreground (7) so the branch reads like normal text.
zstyle ':prompt:pure:git:branch' color 7

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

# Home/End keys
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[1~" beginning-of-line # Alternative Home
bindkey "^[[4~" end-of-line       # Alternative End

# Ctrl+Left/Right for word jumping
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Ctrl+Backspace/Delete for word deletion
bindkey "^H" backward-kill-word
bindkey "^[[3;5~" kill-word

# Aliases
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

# Non-interactive shells: bail out early.
case $- in *i*) ;; *) return ;; esac
# Launch byobu if not already running somewhere (interactive shells only).
if command -v byobu >/dev/null && [[ -z "$TMUX" ]] && ! tmux ls &>/dev/null && [[ -z "$CI" ]]; then
    exec byobu
fi

eval "$(zoxide init zsh --cmd c)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
# Add scout-tools to PATH
[[ "$PATH" != *"$HOME/.local/bin"* ]] && export PATH="$PATH:$HOME/.local/bin" || true
source /home/morten/.scoutrc
alias claude='CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir /home/morten/workspace/software-agent-context'
