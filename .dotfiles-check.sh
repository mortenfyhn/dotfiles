#!/usr/bin/env bash

# The single source of truth for the checks: CI and the pre-push hook both run
# this script, so they can't drift apart. Installs nothing, so it stays fast.

set -Eeuo pipefail

# Go to the directory of this script. The pre-push hook can start in a
# different directory.
cd "$(dirname "$0")"

# Lint all tracked files that start with a bash or sh shebang
mapfile -t scripts < <(git --git-dir="$HOME"/.dotfiles ls-files -z |
    xargs -0 awk 'FNR == 1 && /^#!(.*[\/ ])?(ba)?sh$/ { print FILENAME } { nextfile }')
shellcheck "${scripts[@]}"
shfmt -i 4 -d "${scripts[@]}"

# .zshrc gets the formatter but not shellcheck, which doesn't read zsh
shfmt -i 4 -d .zshrc

# Catch a Sublime project file that no longer matches the tracked files
diff <(./.dotfiles-update-project.sh) .dotfiles.sublime-project

echo -e "\e[1;32mChecks passed\n\e[0m"
