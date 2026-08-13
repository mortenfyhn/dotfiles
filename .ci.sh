#!/usr/bin/env bash

set -Eeuo pipefail

# Just a super simple way to run roughly the same checks as CI locally before pushing.
# Doesn't deal with installs or anything.

shellcheck ~/.install-dotfiles.sh ~/.dotfiles-update-project.sh
shfmt -i 4 -d ~/.install-dotfiles.sh ~/.dotfiles-update-project.sh
shfmt -i 4 -d ~/.zshrc
# Catch a Sublime project file that no longer matches the tracked files
diff <(~/.dotfiles-update-project.sh) ~/.dotfiles.sublime-project
echo -e "\e[1;32mChecks passed\n\e[0m"

~/.install-dotfiles.sh
