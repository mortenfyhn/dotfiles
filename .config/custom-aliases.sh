# single letter
alias l='ls'
alias o='xdg-open'
alias t='trash'
alias z='source $HOME/.zshrc'

# dotfiles
alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias d='dots'

# git
alias g='git'
alias ga='git add'
alias gap='git add -p'
alias gb='git branch'
alias gbd='git branch -d'
alias gbdm='git branch --merged | grep -v "(^\*|master)" | xargs git branch -d'
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
alias gl='git log --decorate --oneline --graph'
alias gl20='gl -20'
alias gl40='gl -40'
alias gla='git log --all --decorate --oneline --graph'
alias gla20='gla -20'
alias gla40='gla -40'
alias gls='git log --source --all -S'
alias gpf='git push --force'
alias gpl='git pull'
alias gps='git push'
alias gpop='git reset HEAD^'
alias gr='git rebase'
alias gra='git rebase --abort'
alias grc='git rebase --continue'
alias grs='git rebase --skip'
alias grom='git rebase master'
alias grim='git rebase -i master'
alias gs='git status'
alias gsa='git stash apply'
alias gsd='git stash drop'
alias gsp='git stash pop'
alias gssh='git --no-pager stash show'
alias gss='git stash save'
alias gsh='git show'
alias gsl='git --no-pager stash list'

# git without prefix
alias fetch='git fetch'
alias pull='git pull'
alias push='git push'
alias fush='git push --force'

# sublime
alias sa='subl -a'
alias sn='subl -n'

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

# calculator
alias calc='mate-calc -s'
