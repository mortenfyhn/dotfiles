#!/usr/bin/env bash

set -e
shopt -s expand_aliases

# Add Vivaldi repos
# https://help.vivaldi.com/desktop/install-update/manual-setup-vivaldi-linux-repositories/
# This seems to be idempotent ✅
wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor | sudo dd of=/usr/share/keyrings/vivaldi-browser.gpg
echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] https://repo.vivaldi.com/archive/deb/ stable main" | sudo dd of=/etc/apt/sources.list.d/vivaldi-archive.list

# Add Sublime Text repos
# https://www.sublimetext.com/docs/linux_repositories.html
# This seems to be idempotent ✅
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

# Install system packages
sudo apt-get update -qq
sudo apt-get upgrade -qq
sudo apt-get install -qq \
    apt-transport-https \
    build-essential \
    ccache \
    clang \
    clang-format \
    clang-tidy \
    cloc \
    cmake \
    cmake-curses-gui \
    curl \
    fd-find \
    gdb \
    git \
    htop \
    lldb \
    meld \
    minicom \
    mosh \
    neofetch \
    ninja-build \
    nmap \
    python3-gpg \
    python3-pip \
    qbittorrent \
    shellcheck \
    silversearcher-ag \
    sublime-merge \
    sublime-text \
    tldr \
    trash-cli \
    tree \
    vivaldi-stable \
    wget \
    xbacklight \
    xclip \
    zsh

# Create alias 'fd' for fd-find
mkdir -p ~/.local/bin
ln --force --symbolic "$(which fdfind)" ~/.local/bin/fd

# Install Python packages
pip3 install -q \
    black \
    cmakelang \
    gita

# Install micro
curl https://getmic.ro | bash
mv micro ~/.local/bin

# Setup ccache
sudo /usr/sbin/update-ccache-symlinks

# Setup ZSH with oh-my-zsh
if [[ -z "$ZSH" ]]
then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
    echo "Changing login shell to ZSH..."
    chsh -s "$(command -v zsh)"
fi

# Setup ZSH themes and plugins
ZSH_CUSTOM=~/.oh-my-zsh/custom
wget -q -O "$ZSH_CUSTOM/themes/bullet-train.zsh-theme" https://raw.githubusercontent.com/caiogondim/bullet-train.zsh/master/bullet-train.zsh-theme
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    git clone --quiet https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-256color" ]]; then
    git clone --quiet https://github.com/chrissicool/zsh-256color.git "$ZSH_CUSTOM/plugins/zsh-256color"
fi
font_dir=$(mktemp -d)
git clone --quiet --depth=1 https://github.com/powerline/fonts.git "$font_dir" && "$font_dir/install.sh"

# Clone dotfiles
grep -sqxF ".dotfiles" ~/.gitignore || echo ".dotfiles" >> ~/.gitignore
if [[ ! -d ~/.dotfiles ]]; then
    git clone -q --bare git@github.com:mortenfyhn/dotfiles.git ~/.dotfiles
    alias dots='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    dots checkout --force
    dots config --local status.showUntrackedFiles no
    dots config --local --add remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    dots fetch
fi

# Load dconf settings
dconf load /org/mate/terminal/profiles/default/ < ~/.config/dotfiles/dconf/mate-terminal
dconf load /org/mate/marco/window-keybindings/ < ~/.config/dotfiles/dconf/shortcuts
dconf load /org/mate/desktop/peripherals/keyboard/kbd/ < ~/.config/dotfiles/dconf/keyboard

# Remap keyboard (use caps lock key as alt gr)
# Patch returns 1 if the patch already has been applied, so I hide the exit code and then check the text output to make this idempotent
if patch_output=$(sudo patch --unified --backup --forward --reject-file=- /usr/share/X11/xkb/symbols/pc --input="$HOME"/.config/dotfiles/remap-caps-lock.patch)
then
    echo "Applied keyboard patch"
else
    if echo "$patch_output" | grep -q "Reversed (or previously applied) patch detected!"
    then
        echo "Keyboard patch already applied"
    else
        echo "Failed to apply keyboard patch"
        exit 1
    fi
fi

# Install Broot's "br" shell function
broot --install

echo "Done! Log out and back in again."
