#!/usr/bin/env bash

set -Eeuo pipefail
shopt -s expand_aliases

# Echo bold text (green)
bold() {
    echo -e "\e[1;32m$*\e[0m"
}

headless=false
while [[ $# -gt 0 ]]; do
    case "$1" in
    --headless)
        headless=true
        shift
        ;;
    esac
done

# Install newest version of git
bold "Adding PPA for most current stable version of Git"
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt update -qq
sudo apt upgrade -qq
echo "Done"

bold "Configure git"
git config --global user.name "Morten Fyhn Amundsen"
git config --global core.pager "less -F -X"
git config --global core.excludesfile "~/.gitignore-global"
git config --global merge.conflictStyle zdiff3
git config --global init.defaultBranch master
git config --global fetch.prune true
git config --global pull.ff only
git config --global push.default current
git config --global help.autocorrect 1
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
    wget -qO iosevka.zip https://github.com/be5invis/Iosevka/releases/download/v16.3.4/super-ttc-iosevka-16.3.4.zip
    unzip iosevka.zip
    mkdir -p ~/.local/share/fonts
    mv iosevka.ttc ~/.local/share/fonts
    fc-cache -f
    popd >/dev/null
fi

# Install system packages
bold "Installing apt packages"
sudo apt-get update -qq
sudo apt-get upgrade -qq
sudo apt-get install -qq \
    apt-transport-https \
    build-essential \
    byobu \
    ccache \
    clang \
    clang-format \
    clang-tidy \
    cloc \
    cmake \
    curl \
    git \
    gparted \
    htop \
    less \
    meld \
    minicom \
    mosh \
    ncdu \
    neofetch \
    ninja-build \
    nmap \
    python3-gpg \
    python3-pip \
    shellcheck \
    silversearcher-ag \
    tldr \
    trash-cli \
    tree \
    unzip \
    wget \
    xclip \
    zsh
echo "Done"

# Install and configure fd-find
# Do nothing if unavailable
bold "Installing fd-find"
if sudo apt-get install -qq fd-find; then
    mkdir -p ~/.local/bin
    ln --force --symbolic "$(which fdfind)" ~/.local/bin/fd
else
    echo "Cannot install fd-find, continuing..."
fi
echo "Done"

# Install Python packages
bold "Installing Python packages"
pip3 install -q \
    black \
    cmakelang
echo "Done"

# Setup ccache
bold "Setting up ccache"
sudo /usr/sbin/update-ccache-symlinks
echo "Done"

# Setup ZSH with oh-my-zsh
bold "Setting up Oh My Zsh"
if [[ ! -d ~/.oh-my-zsh ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
echo "Done"

# Set ZSH as default shell
bold "Make ZSH default shell"
if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
    echo "Changing login shell to ZSH..."
    chsh -s "$(command -v zsh)"
fi
echo "Done"

# Setup ZSH themes and plugins
bold "Configuring ZSH"
ZSH_CUSTOM=~/.oh-my-zsh/custom
wget -qO "$ZSH_CUSTOM/themes/bullet-train.zsh-theme" https://raw.githubusercontent.com/caiogondim/bullet-train.zsh/master/bullet-train.zsh-theme
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    git clone --quiet https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-256color" ]]; then
    git clone --quiet https://github.com/chrissicool/zsh-256color.git "$ZSH_CUSTOM/plugins/zsh-256color"
fi
font_dir=$(mktemp -d)
git clone --quiet --depth=1 https://github.com/powerline/fonts.git "$font_dir" && "$font_dir/install.sh"
echo "Done"

# Load dconf settings
bold "Load MATE desktop environment settings"
if command -v dconf >/dev/null; then
    dconf load /org/mate/terminal/profiles/default/ <~/.config/dotfiles/dconf/mate-terminal
    dconf load /org/mate/marco/window-keybindings/ <~/.config/dotfiles/dconf/shortcuts
    dconf load /org/mate/desktop/peripherals/keyboard/kbd/ <~/.config/dotfiles/dconf/keyboard
else
    echo "Cannot find dconf, won't load dconf settings"
fi
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

bold "Updating tldr cache"
tldr --update || : # Seems to sometimes fail when run repeatedly, but that's ok
echo "Done"

bold "All done! Log out and back in again."
