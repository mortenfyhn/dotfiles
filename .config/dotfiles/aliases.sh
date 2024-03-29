#!/usr/bin/env bash

# single letter
alias d='dots'
alias g='git'
alias l='ls'
alias o='xdg-open'
alias t='trash'
alias z='source $HOME/.zshrc'

# dotfiles
alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# sublime
alias sa='subl -a'
alias sn='subl -n'

# python
alias py='python3'

# navigation
alias ..='cd ..'
alias ...='cd ../..'

# git
alias ga='git add'
alias gb='git branch'
alias gbd='gb -d'
alias gbD='gb -D'
alias gc='git commit'
alias gcm='gc -m'
alias gca='gc --amend'
alias gcan='gca --no-edit'
alias gch='git checkout'
alias gchb='gch -b'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gl='git log --decorate --oneline --graph'
alias gla='gl --all'
alias glas='gla --simplify-by-decoration'
alias gl20='gl -20'
alias gla20='gla -20'
alias gps='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gr='git rebase'
alias gra='gr --abort'
alias grc='gr --continue'
alias grs='gr --skip'
alias grom='gr master'
alias grim='gr -i master'
alias gs='git status'
alias gsh='git show'
alias gsw='git switch'
