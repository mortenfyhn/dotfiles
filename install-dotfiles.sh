#!/usr/bin/env bash

set -Eeuo pipefail
shopt -s expand_aliases

red() { echo -e "\e[31m$*\e[0m"; }
green() { echo -e "\e[32m$*\e[0m"; }
yellow() { echo -e "\e[33m$*\e[0m"; }
blue() { echo -e "\e[36m$*\e[0m"; }
bold() { echo -e "\e[1m$*\e[0m"; }
bold_red() { echo -e "\e[1;31m$*\e[0m"; }
bold_green() { echo -e "\e[1;32m$*\e[0m"; }
bold_yellow() { echo -e "\e[1;33m$*\e[0m"; }
bold_blue() { echo -e "\e[1;36m$*\e[0m"; }

headless=false
while [[ $# -gt 0 ]]; do
    case "$1" in
    --headless)
        headless=true
        shift
        ;;
    *)
        echo "Error: Invalid option '$1'"
        exit 1
        ;;
    esac
done

# Clone dotfiles
bold_blue "Cloning dotfiles repo"
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

bold_blue "Installing applications"
common_packages=(bat byobu ccache git zsh)
if command -v apt >/dev/null; then # Ubuntu
    sudo apt-get --quiet --quiet update
    sudo add-apt-repository --yes --no-update ppa:git-core/ppa
    sudo apt-get --quiet --quiet install "${common_packages[@]}"
elif command -v dnf >/dev/null; then # Fedora
    sudo dnf --assumeyes --quiet install "${common_packages[@]}"
else
    echo "I only support apt and dnf"
fi

bold_blue "Configure git"
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

if [[ "$headless" = false ]]; then
    # Install Iosevka font (for my editor)
    bold_blue "Installing Iosevka font"
    if [[ -f ~/.local/share/fonts/Iosevka.ttc ]]; then
        echo "Already installed"
    else
        pushd "$(mktemp --directory)" >/dev/null
        wget -q https://github.com/be5invis/Iosevka/releases/download/v33.2.3/SuperTTC-Iosevka-33.2.3.zip -O Iosevka.zip
        unzip Iosevka.zip
        mkdir -p ~/.local/share/fonts
        mv Iosevka.ttc ~/.local/share/fonts
        fc-cache -f
        popd >/dev/null
    fi
fi

# Install difftastic
bold_blue "Installing difftastic"
if command -v difft >/dev/null; then
    echo "Already installed"
else
    pushd "$(mktemp --directory)" >/dev/null
    wget -q https://github.com/Wilfred/difftastic/releases/download/0.64.0/difft-x86_64-unknown-linux-gnu.tar.gz
    tar -xzf difft-x86_64-unknown-linux-gnu.tar.gz
    mkdir -p ~/.local/bin
    mv difft ~/.local/bin/difft
    popd >/dev/null
fi
if difft --version &>/dev/null; then
    git config --global diff.external difft
else
    # See https://github.com/mortenfyhn/dotfiles/issues/89
    git config unset --global diff.external || :
fi
echo "Done"

# Remap keyboard
# Note: Patch returns 1 if the patch already has been applied, so I hide the exit code and then check the text output to make this idempotent
bold_blue "Remapping keyboard"
# Patch 1: Remap caps lock to alt gr
if patch_output=$(sudo patch --unified --backup --forward --reject-file=- /usr/share/X11/xkb/symbols/pc --input="$HOME"/.config/dotfiles/remap-caps-lock.patch); then
    echo "Applied keyboard patch 1"
else
    if echo "$patch_output" | grep -q "Reversed (or previously applied) patch detected!"; then
        echo "Keyboard patch 1 already applied"
    else
        yellow "Failed to apply keyboard patch 1"
    fi
fi
# Patch 2: Don't spit out non-breaking space for alt gr + space (common "mistake" when typing a space after a bracket)
if patch_output=$(sudo patch --unified --backup --forward --reject-file=- /usr/share/X11/xkb/symbols/no --input="$HOME"/.config/dotfiles/non-breaking-space.patch); then
    echo "Applied keyboard patch 2"
else
    if echo "$patch_output" | grep -q "Reversed (or previously applied) patch detected!"; then
        echo "Keyboard patch 2 already applied"
    else
        yellow "Failed to apply keyboard patch 2"
    fi
fi
echo "Done"

# Install ZSH prompt (pure)
bold_blue "Installing 'Pure' prompt"
mkdir -p "$HOME/.zsh"
if [[ -d "$HOME/.zsh/pure" ]]; then
    echo "Already installed"
else
    git clone git@github.com:sindresorhus/pure.git "$HOME/.zsh/pure"
    echo "Done"
fi

# Install zsh-autosuggestions
bold_blue "Installing zsh-autosuggestions"
mkdir -p "$HOME/.zsh"
if [[ -d "$HOME/.zsh/zsh-autosuggestions" ]]; then
    echo "Already installed"
else
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"
    echo "Done"
fi

# Make ZSH the default shell
bold_blue "Make ZSH default shell"
need_relog=false
if [[ "$SHELL" == "/usr/bin/zsh" ]]; then
    echo "Default shell is already ZSH"
elif [[ -n "$CI" ]]; then
    echo "Running in CI, skipping"
else
    chsh -s "$(command -v zsh)"
    need_relog=true
fi
echo "Done"

bold_green "All done!"
if [[ $need_relog == true ]]; then
    bold "Log out and back in again."
fi
if [[ "$headless" = false ]] && command -v dnf >/dev/null; then # Fedora
    echo "Manual UI setup: https://github.com/mortenfyhn/dotfiles/issues/83"
fi
