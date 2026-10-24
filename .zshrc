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
zstyle ':prompt:pure:prompt:success' color 34 # Green
zstyle ':prompt:pure:prompt:error' color 202  # Red
PURE_PROMPT_SYMBOL='%(?..%? )%B❯%b'           # Nice caret

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
WORDCHARS=${WORDCHARS//[\/.-]/} # Move/delete words one path segment at a time.
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end # Up: older prefix matches; empty prefix matches all.
bindkey "^[[B" history-beginning-search-forward-end  # Down: newer matches, then restore the typed prefix.
bindkey "^[[H" beginning-of-line                     # Home
bindkey "^[[F" end-of-line                           # End
bindkey "^[[1~" beginning-of-line                    # Home (alternate encoding)
bindkey "^[[4~" end-of-line                          # End (alternate encoding)
bindkey "^[[1;5C" forward-word                       # Ctrl+Right
bindkey "^[[1;5D" backward-word                      # Ctrl+Left
bindkey "^H" backward-kill-word                      # Ctrl+Backspace
bindkey "^[[3;5~" kill-word                          # Ctrl+Delete

# Aliases
source $HOME/.aliases

# Installing bat on Ubuntu gives "batcat"...
if command -v batcat >/dev/null; then
    alias bat=batcat
fi

# Add stuff to PATH
path+=("$HOME/.local/bin")
typeset -U path

# Local machine-specific setup, not tracked.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Zoxide smart directory jumping
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd c)"

# Exiting tmux closes the terminal.
if [[ -z "$TMUX" ]] && command -v tmux >/dev/null; then
    exec tmux
fi
