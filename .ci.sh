#!/usr/bin/env bash

set -Eeuo pipefail

# Just a super simple way to run roughly the same checks as CI locally before pushing.
# Doesn't deal with installs or anything.

shellcheck ~/install-dotfiles.sh
shfmt -i 4 -d ~/install-dotfiles.sh
shfmt -i 4 -d ~/.zshrc
echo -e "\e[1;32mChecks passed\n\e[0m"

~/install-dotfiles.sh
