# single letter
alias g='git'
alias e='exit'
alias l='ls'
alias z='source $HOME/.zshrc'
alias t='trash'
alias o='xdg-open'
alias 3='tree -L 3'

# dotfiles
alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# git
alias ga='git add'
alias gap='git add -p'
alias gb='git branch'
alias gbdm='git branch --merged | egrep -v "(^\*|master)" | xargs git branch -d'
alias gc='git commit'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gch='git checkout'
alias gchb='git checkout -b'
alias gcm='git commit -m'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gl='git log --branches --remotes --decorate --oneline --graph'
alias gla='git log --all --decorate --oneline --graph'
alias gl2='gl20'
alias gl20='git --no-pager log --branches --remotes --decorate --oneline --graph -20'
alias gla20='git --no-pager log --all --decorate --oneline --graph -20'
alias gl4='gl40'
alias gl40='git --no-pager log --branches --remotes --decorate --oneline --graph -40'
alias gla40='git --no-pager log --all --decorate --oneline --graph -40'
alias gls='git log --source --all -S'
alias gpf='git push --force'
alias gpl='git pull'
alias gps='git push'
alias gpop='git reset HEAD^'
alias gr='git rebase'
alias grom='git rebase master'
alias gs='git status'
alias gsa='git stash apply'
alias gsd='git stash drop'
alias gsp='git stash pop'
alias gssh='git --no-pager stash show'
alias gss='git stash save'
alias gsh='git show'
alias gsl='git --no-pager stash list'

# git without prefix
alias pull='git pull'
alias push='git push'
alias fush='git push --force'

# dune
alias db='dune_build'
alias dr='dune_rebuild'

# sublime
alias sa='subl -a'
alias sn='subl -n'
alias zz='subl -a $HOME/.zshrc'

# file system
alias filesize='ls -lh'
alias dirsize='du -sh'
alias findfile='find . -name'
alias linecount='wc -l'

# network
alias vpn='sudo openconnect --user=mortefam https://sslvpn.ntnu.no/'

# sounds
alias successbeep='beep -f 500 -l 50'
alias errorbeep='beep -f 250 -l 100'

# python/conda
alias syspy2="/usr/bin/python2"
alias syspy3="/usr/bin/python3"
alias pyscout="source activate scout"

# weird stuff
alias weather="curl wttr.in/Trondheim"
alias three="three -L 3"

# haskell
alias hask='cd $HOME/Cloud/Projects/Haskell/CIS194/'
alias ghci='stack ghci'
