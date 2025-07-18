#!/usr/bin/env bash

set -Eeuo pipefail
shopt -s expand_aliases

# Echo bold text (green)
bold() { echo -e "\e[1;32m$*\e[0m"; }

headless=false
ci=false
while [[ $# -gt 0 ]]; do
    case "$1" in
    --headless)
        headless=true
        shift
        ;;
    --ci)
        ci=true
        shift
        ;;
    esac
done

bold "Configure git"
git config --global user.name "Morten Fyhn Amundsen"
git config --global merge.conflictStyle zdiff3
git config --global fetch.prune true
git config --global pull.ff only
git config --global help.autocorrect 20
git config --global init.defaultBranch master
if [[ "$headless" = false ]]; then
    git config --global core.editor "subl -n -w"
fi
echo "Done"

# Clone dotfiles
bold "Cloning dotfiles repo"
grep -sqxF ".dotfiles" ~/.gitignore || echo ".dotfiles" >>~/.gitignore
if [[ ! -d ~/.dotfiles ]]; then
    git clone -q --bare git@github.com:mortenfyhn/dotfiles.git ~/.dotfiles
    dots() { git --git-dir="$HOME"/.dotfiles/ --work-tree="$HOME" "$@"; }
    dots checkout --force
    dots config --local status.showUntrackedFiles no
    dots config --local --add remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    dots fetch
fi
echo "Done"

if [[ "$headless" = false ]]; then
    # Install Iosevka font (for my editor)
    bold "Installing Iosevka font"
    pushd "$(mktemp --directory)" >/dev/null
    wget -q https://github.com/be5invis/Iosevka/releases/download/v33.2.3/SuperTTC-Iosevka-33.2.3.zip -O Iosevka.zip
    unzip Iosevka.zip
    mkdir -p ~/.local/share/fonts
    mv Iosevka.ttc ~/.local/share/fonts
    fc-cache -f
    popd >/dev/null
fi

# Install difftastic
bold "Installing difftastic"
pushd "$(mktemp --directory)" >/dev/null
wget -q https://github.com/Wilfred/difftastic/releases/download/0.64.0/difft-x86_64-unknown-linux-gnu.tar.gz
tar -xzf difft-x86_64-unknown-linux-gnu.tar.gz
mv difft ~/.local/bin/difft
popd >/dev/null
echo "Done"

# Remap keyboard
# Note: Patch returns 1 if the patch already has been applied, so I hide the exit code and then check the text output to make this idempotent
bold "Remapping keyboard"
# Patch 1: Remap caps lock to alt gr
if patch_output=$(sudo patch --unified --backup --forward --reject-file=- /usr/share/X11/xkb/symbols/pc --input="$HOME"/.config/dotfiles/remap-caps-lock.patch); then
    echo "Applied keyboard patch 1"
else
    if echo "$patch_output" | grep -q "Reversed (or previously applied) patch detected!"; then
        echo "Keyboard patch 1 already applied"
    else
        echo "Failed to apply keyboard patch 1"
        exit 1
    fi
fi
# Patch 2: Don't spit out non-breaking space for alt gr + space (common "mistake" when typing a space after a bracket)
if patch_output=$(sudo patch --unified --backup --forward --reject-file=- /usr/share/X11/xkb/symbols/no --input="$HOME"/.config/dotfiles/non-breaking-space.patch); then
    echo "Applied keyboard patch 2"
else
    if echo "$patch_output" | grep -q "Reversed (or previously applied) patch detected!"; then
        echo "Keyboard patch 2 already applied"
    else
        echo "Failed to apply keyboard patch 2"
        exit 1
    fi
fi
echo "Done"

# Make ZSH the default shell
bold "Make ZSH default shell"
if [[ "$SHELL" == "/usr/bin/zsh" ]]; then
    echo "Default shell is already ZSH"
elif [[ "$ci" = true ]]; then
    echo "Running in CI, skipping"
else
    chsh -s "$(command -v zsh)"
fi
echo "Done"

bold "All done! Log out and back in again."
