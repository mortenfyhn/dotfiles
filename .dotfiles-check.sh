#!/usr/bin/env bash

# The single source of truth for the checks: .semaphore/semaphore.yml just runs
# this script, so CI and a local pre-push run can't drift apart. Installs
# nothing, so it stays fast.

set -Eeuo pipefail

# Work on the repo this script lives in: $HOME when run locally, the checkout
# when run in CI.
cd "$(dirname "$0")"

scripts=(.dotfiles-check.sh .dotfiles-update-project.sh .dotfiles-install.sh)
shellcheck "${scripts[@]}"
shfmt -i 4 -d "${scripts[@]}"

# .zshrc gets the formatter but not shellcheck, which doesn't read zsh
shfmt -i 4 -d .zshrc

# Catch a Sublime project file that no longer matches the tracked files
diff <(./.dotfiles-update-project.sh) .dotfiles.sublime-project

echo -e "\e[1;32mChecks passed\n\e[0m"
