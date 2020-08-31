#!/usr/env/bin bash

set -e
shopt -s expand_aliases

# Add system package repositories
wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo apt-key add -
sudo add-apt-repository 'deb https://repo.vivaldi.com/archive/deb/ stable main'
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo add-apt-repository 'deb https://download.sublimetext.com/ apt/stable/'

# echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

# Install system packages
sudo apt-get update -qq
sudo apt-get upgrade -qq -y
sudo apt-get install -qq -y \
    apt-transport-https \
    build-essential \
    ccache \
    clang \
    clang-format \
    clang-tidy \
    cmake \
    cmake-curses-gui \
    curl \
    gdb \
    git \
    htop \
    lldb \
    minicom \
    mosh \
    neofetch \
    ninja-build \
    nmap \
    python-pip \
    python3-pip \
    shellcheck \
    sublime-merge \
    sublime-text \
    trash-cli \
    tree \
    vivaldi-stable \
    wget \
    xclip \
    zsh \

# Install Python packages
pip3 install -q \
    black \
    cmakelang \
    thefuck \

# Setup ccache
sudo /usr/sbin/update-ccache-symlinks

# Setup ZSH with oh-my-zsh and themes/plugins
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s "$(which zsh)"
ZSH_CUSTOM=~/.oh-my-zsh/custom
wget -q -O "$ZSH_CUSTOM/themes/bullet-train.zsh-theme" https://raw.githubusercontent.com/caiogondim/bullet-train.zsh/master/bullet-train.zsh-theme
git clone -q https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone -q https://github.com/chrissicool/zsh-256color.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-256color"
git clone -q https://github.com/powerline/fonts.git --depth=1 /tmp/fonts && /tmp/fonts/install.sh

# Clone dotfiles
grep -sqxF ".dotfiles" ~/.gitignore || echo ".dotfiles" >> ~/.gitignore
git clone -q --bare https://github.com/mortenfyhn/dotfiles.git ~/.dotfiles
alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dots checkout --force
dots config --local status.showUntrackedFiles no

# Load dconf settings
dconf load /org/mate/terminal/profiles/default/ < ~/.config/dotfiles/dconf/mate-terminal
dconf load /org/mate/marco/window-keybindings/ < ~/.config/dotfiles/dconf/shortcuts
dconf load /org/mate/desktop/peripherals/keyboard/kbd/ < ~/.config/dotfiles/dconf/keyboard

# Remap keyboard
sudo patch -u -b /usr/share/X11/xkb/symbols/pc -i ~/.config/dotfiles/remap-caps-lock.patch

echo "Done! Log out and back in again."
